import 'dart:io';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/report_service.dart';
import '../services/api_service.dart';

/// Report state provider — manages citizen reports and government review.
class ReportProvider extends ChangeNotifier {
  final ReportService _reportService;

  List<CitizenReport> _reports = [];
  List<CitizenReport> _myReports = [];
  CitizenReport? _selectedReport;
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0.0;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;

  ReportProvider({required ReportService reportService})
      : _reportService = reportService;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<CitizenReport> get reports => _reports;
  List<CitizenReport> get myReports => _myReports;
  CitizenReport? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  // ─── Load Reports ──────────────────────────────────────────────────────────
  Future<void> loadReports({
    String? status,
    String? category,
    String? projectId,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _reports.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _reportService.getReports(
        status: status,
        category: category,
        projectId: projectId,
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _reports = response.data;
      } else {
        _reports.addAll(response.data);
      }

      _totalPages = response.totalPages;
      _hasMore = response.hasNext;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Load My Reports ───────────────────────────────────────────────────────
  Future<void> loadMyReports({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _myReports.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _reportService.getMyReports(
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _myReports = response.data;
      } else {
        _myReports.addAll(response.data);
      }

      _hasMore = response.hasNext;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Load Report Details ───────────────────────────────────────────────────
  Future<void> loadReportDetails(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedReport = await _reportService.getReportById(reportId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedReport() {
    _selectedReport = null;
    notifyListeners();
  }

  // ─── Create Report (Citizen) ───────────────────────────────────────────────
  Future<CitizenReport> createReport({
    required String projectId,
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
    double? locationLat,
    double? locationLng,
    List<File>? evidenceFiles,
  }) async {
    _setLoading(true);
    _clearError();
    _uploadProgress = 0.0;

    try {
      // Create report first
      final report = await _reportService.createReport(
        projectId: projectId,
        title: title,
        description: description,
        category: category,
        isAnonymous: isAnonymous,
        locationLat: locationLat,
        locationLng: locationLng,
      );

      // Upload evidence if provided
      if (evidenceFiles != null && evidenceFiles.isNotEmpty) {
        await _reportService.uploadEvidence(
          reportId: report.id,
          files: evidenceFiles,
          onProgress: (sent, total) {
            _uploadProgress = sent / total;
            notifyListeners();
          },
        );
      }

      // Add to my reports list
      _myReports.insert(0, report);
      _uploadProgress = 0.0;
      notifyListeners();
      return report;
    } on ApiException catch (e) {
      _error = e.message;
      _uploadProgress = 0.0;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Update Report Status (Government) ─────────────────────────────────────
  Future<CitizenReport> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? response,
    String? actionTaken,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updated = await _reportService.updateReportStatus(
        reportId: reportId,
        status: status.name,
        response: response,
        actionTaken: actionTaken,
      );

      // Update in lists
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = updated;
      }

      final myIndex = _myReports.indexWhere((r) => r.id == reportId);
      if (myIndex != -1) {
        _myReports[myIndex] = updated;
      }

      if (_selectedReport?.id == reportId) {
        _selectedReport = updated;
      }

      notifyListeners();
      return updated;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Filter Reports ────────────────────────────────────────────────────────
  Future<void> filterByStatus(String status) async {
    await loadReports(status: status, refresh: true);
  }

  Future<void> filterByCategory(String category) async {
    await loadReports(category: category, refresh: true);
  }

  Future<void> filterByProject(String projectId) async {
    await loadReports(projectId: projectId, refresh: true);
  }

  // ─── Statistics ────────────────────────────────────────────────────────────
  int get totalReports => _reports.length;
  int get pendingReports =>
      _reports.where((r) => r.status == ReportStatus.submitted).length;
  int get underReviewReports =>
      _reports.where((r) => r.status == ReportStatus.underReview).length;
  int get resolvedReports =>
      _reports.where((r) => r.status == ReportStatus.resolved).length;

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
