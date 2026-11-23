import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/models.dart';
import '../models/government.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../../core/constants/app_constants.dart';

/// Auth state — ported from authStore.ts using Flutter Provider.
/// Manages login, register, logout, and session validation.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecurityService _securityService;

  User? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required SecurityService securityService,
    required FlutterSecureStorage secureStorage,
  })  : _authService = authService,
        _securityService = securityService;

  // ─── Getters ───────────────────────────────────────────────────────────────
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCitizen => _user?.role == UserRole.citizen;
  bool get isGovernment => _user?.role == UserRole.government;

  // ─── Initialize (restore session on app start) ─────────────────────────────
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final hasValidSession = await _authService.hasValidSession();
      if (hasValidSession) {
        final storedUser = await _authService.getStoredUser();
        if (storedUser != null) {
          _user = storedUser;
          _isAuthenticated = true;
          // Touch session activity
          await _securityService.updateSessionActivity();
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        role: role,
      );
      _user = result.user;
      _token = result.token;
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Register ───────────────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? cnic,
    String? phone,
    String? province,
    String? district,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        cnic: cnic,
        phone: phone,
        province: province,
        district: district,
      );
      // Registration sends OTP — don't auto-login yet
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── OTP Verification ───────────────────────────────────────────────────────
  Future<void> verifyOTP({required String email, required String otp}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyOTP(email: email, otp: otp);
      _user = result.user;
      _token = result.token;
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final userId = _user?.id ?? '';
    _user = null;
    _token = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();

    // Best-effort server logout
    try {
      await _authService.logout(userId);
    } catch (_) {}
  }

  // ─── Update User ────────────────────────────────────────────────────────────
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updated = await _authService.updateProfile(updates);
      _user = updated;
      if (_user != null) {
        await _securityService.createAuditLog(
          _user!.id,
          'UPDATE_PROFILE',
          'user',
          details: updates,
        );
      }
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Set government role (for government registration flow).
  void setGovernmentRole(GovernmentRole role) {
    if (_user == null) return;
    final info = governmentHierarchy[role];
    _user = _user!.copyWith(
      governmentRole: role,
      employeeCode: 'PAK-${role.name.toUpperCase()}-001',
      designation: info?.title,
      approvalAuthority: info?.canApproveUpTo,
    );
    notifyListeners();
  }

  /// Check if the current session is still valid and refresh activity.
  Future<bool> checkSessionValidity() async {
    final session = await _securityService.getSession();
    final isValid = _securityService.validateSession(session);
    if (!isValid && _isAuthenticated) {
      await logout();
      return false;
    }
    if (isValid) {
      await _securityService.updateSessionActivity();
    }
    return isValid;
  }

  void clearError() => _clearError();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
