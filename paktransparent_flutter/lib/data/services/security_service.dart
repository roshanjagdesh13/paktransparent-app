import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';

/// Security service — Dart port of securityService.ts.
/// All browser APIs (sessionStorage, localStorage, navigator, document, window)
/// are replaced with Flutter-native equivalents (FlutterSecureStorage).
class SecurityService {
  final FlutterSecureStorage _secureStorage;
  final _random = Random.secure();

  // In-memory rate limiting (resets on app restart — acceptable for mobile)
  final Map<String, _RateLimitEntry> _rateLimitStore = {};
  final Map<String, _LockoutEntry> _lockoutStore = {};

  SecurityService({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  // ─── Password Hashing ─────────────────────────────────────────────────────

  /// Hash password using SHA-256 with a random salt.
  /// Returns "salt:hash" format.
  String hashPassword(String password) {
    final salt = generateSecureToken(length: 16);
    final bytes = utf8.encode('$password$salt');
    final hash = sha256.convert(bytes).toString();
    return '$salt:$hash';
  }

  /// Verify a plain password against a stored "salt:hash".
  bool verifyPassword(String password, String hashedPassword) {
    final parts = hashedPassword.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final storedHash = parts[1];
    final bytes = utf8.encode('$password$salt');
    final computedHash = sha256.convert(bytes).toString();
    return computedHash == storedHash;
  }

  // ─── Session Management ───────────────────────────────────────────────────

  static const int _sessionDurationMs = 24 * 60 * 60 * 1000; // 24h
  static const int _inactivityTimeoutMs = 30 * 60 * 1000; // 30 min

  Future<SessionData> createSession(String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final session = SessionData(
      token: generateSecureToken(),
      userId: userId,
      expiresAt: now + _sessionDurationMs,
      createdAt: now,
      lastActivity: now,
    );
    await _secureStorage.write(
      key: 'session_data',
      value: jsonEncode(session.toJson()),
    );
    return session;
  }

  Future<SessionData?> getSession() async {
    final data = await _secureStorage.read(key: 'session_data');
    if (data == null) return null;
    try {
      return SessionData.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool validateSession(SessionData? session) {
    if (session == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > session.expiresAt) return false;
    if (now - session.lastActivity > _inactivityTimeoutMs) return false;
    return true;
  }

  Future<void> updateSessionActivity() async {
    final session = await getSession();
    if (session == null) return;
    final updated = session.copyWith(
      lastActivity: DateTime.now().millisecondsSinceEpoch,
    );
    await _secureStorage.write(
      key: 'session_data',
      value: jsonEncode(updated.toJson()),
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'session_data');
  }

  // ─── Rate Limiting ────────────────────────────────────────────────────────

  ({bool allowed, int remaining, int resetAt}) checkRateLimit(
    String key, {
    int maxRequests = 100,
    int windowMs = 60000,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = _rateLimitStore[key];

    if (entry == null || now > entry.resetAt) {
      _rateLimitStore[key] = _RateLimitEntry(count: 1, resetAt: now + windowMs);
      return (allowed: true, remaining: maxRequests - 1, resetAt: now + windowMs);
    }

    entry.count++;
    if (entry.count > maxRequests) {
      return (allowed: false, remaining: 0, resetAt: entry.resetAt);
    }

    return (
      allowed: true,
      remaining: maxRequests - entry.count,
      resetAt: entry.resetAt,
    );
  }

  void resetRateLimit(String key) {
    _rateLimitStore.remove(key);
  }

  // ─── Account Lockout ──────────────────────────────────────────────────────

  static const int _maxAttempts = AppConstants.maxLoginAttempts;
  static const int _lockoutMs = AppConstants.lockoutDurationMinutes * 60 * 1000;

  ({bool locked, int? lockedUntil}) isAccountLocked(String identifier) {
    final entry = _lockoutStore[identifier];
    if (entry == null || entry.lockedUntil == null) return (locked: false, lockedUntil: null);

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > entry.lockedUntil!) {
      _lockoutStore.remove(identifier);
      return (locked: false, lockedUntil: null);
    }

    return (locked: true, lockedUntil: entry.lockedUntil);
  }

  ({bool locked, int attemptsRemaining, int? lockedUntil}) recordFailedLogin(
      String identifier) {
    final entry = _lockoutStore[identifier] ?? _LockoutEntry(attempts: 0);
    entry.attempts++;

    if (entry.attempts >= _maxAttempts) {
      entry.lockedUntil = DateTime.now().millisecondsSinceEpoch + _lockoutMs;
      _lockoutStore[identifier] = entry;
      return (locked: true, attemptsRemaining: 0, lockedUntil: entry.lockedUntil);
    }

    _lockoutStore[identifier] = entry;
    return (
      locked: false,
      attemptsRemaining: _maxAttempts - entry.attempts,
      lockedUntil: null,
    );
  }

  void resetLoginAttempts(String identifier) {
    _lockoutStore.remove(identifier);
  }

  // ─── Input Sanitization ───────────────────────────────────────────────────

  /// Sanitize user input — remove potentially dangerous characters.
  /// In Flutter, XSS is not relevant (native rendering), but sanitizing is
  /// still good practice for data stored/sent to backend.
  String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }

  /// Sanitize a file name for safe storage.
  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_')
        .substring(0, fileName.length.clamp(0, 255));
  }

  // ─── Token Generation ─────────────────────────────────────────────────────

  /// Generate a cryptographically secure random token.
  String generateSecureToken({int length = 32}) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // ─── Audit Logging ────────────────────────────────────────────────────────
  // Simplified audit logging — stores in secure storage.
  // In production, these should be sent to the backend API.

  static const String _auditKey = 'audit_logs';
  static const int _maxAuditLogs = 200; // Lower limit on mobile for memory

  Future<void> createAuditLog(
    String userId,
    String action,
    String resource, {
    bool success = true,
    Map<String, dynamic>? details,
  }) async {
    try {
      final logs = await getAuditLogs();
      logs.insert(0, {
        'id': generateSecureToken(length: 8),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': userId,
        'action': action,
        'resource': resource,
        'success': success,
        'details': details,
      });

      if (logs.length > _maxAuditLogs) {
        logs.removeRange(_maxAuditLogs, logs.length);
      }

      await _secureStorage.write(
        key: _auditKey,
        value: jsonEncode(logs),
      );
    } catch (_) {
      // Non-critical — don't crash the app for audit log failure
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final data = await _secureStorage.read(key: _auditKey);
      if (data == null) return [];
      return (jsonDecode(data) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}

// ─── Supporting Data Classes ──────────────────────────────────────────────────

class SessionData {
  final String token;
  final String userId;
  final int expiresAt;
  final int createdAt;
  final int lastActivity;

  const SessionData({
    required this.token,
    required this.userId,
    required this.expiresAt,
    required this.createdAt,
    required this.lastActivity,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
        token: json['token'] as String,
        userId: json['userId'] as String,
        expiresAt: json['expiresAt'] as int,
        createdAt: json['createdAt'] as int,
        lastActivity: json['lastActivity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'expiresAt': expiresAt,
        'createdAt': createdAt,
        'lastActivity': lastActivity,
      };

  SessionData copyWith({int? lastActivity}) => SessionData(
        token: token,
        userId: userId,
        expiresAt: expiresAt,
        createdAt: createdAt,
        lastActivity: lastActivity ?? this.lastActivity,
      );

  int get timeRemainingMs =>
      (expiresAt - DateTime.now().millisecondsSinceEpoch).clamp(0, expiresAt);
}

class _RateLimitEntry {
  int count;
  int resetAt;

  _RateLimitEntry({required this.count, required this.resetAt});
}

class _LockoutEntry {
  int attempts;
  int? lockedUntil;

  _LockoutEntry({required this.attempts, this.lockedUntil});
}
