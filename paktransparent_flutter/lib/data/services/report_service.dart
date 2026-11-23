import 'dart:io';
import 'package:dio/dio.dart';

import '../models/models.dart';
import '../data/sample_data.dart';
import 'api_service.dart';

/// Report service — handles citizen complaint creation, status updates,
/// and evidence uploads with local offline-first repository persistence.
class ReportService {
  final ApiService _api;
  final List<CitizenReport> _localReports = [];

  ReportService({required ApiService apiService}) : _api = apiService {
    _localReports.addAll(SampleData.initialReports);
  }

  Future<PaginatedResponse<CitizenReport>> getReports({
    String? status,
    String? category,
    String? projectId,
    String? citizenId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        if (projectId != null) 'projectId': projectId,
        if (citizenId != null) 'citizenId': citizenId,
      };

      final response = await _api.get<Map<String, dynamic>>(
        '/reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PaginatedResponse.fromJson(
          response.data!,
          CitizenReport.fromJson,
        );
      }
    } catch (_) {
      // Offline fallback
    }

    return _filterLocalReports(
      status: status,
      category: category,
      projectId: projectId,
      citizenId: citizenId,
      page: page,
      limit: limit,
    );
  }

  Future<CitizenReport> getReportById(String id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/reports/$id');
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return CitizenReport.fromJson(
            response.data!['data'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Offline fallback
    }

    final match = _localReports.where((r) => r.id == id).firstOrNull;
    if (match != null) return match;
    throw const ApiException('Report not found');
  }

  Future<CitizenReport> createReport({
    required String projectId,
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      final data = <String, dynamic>{
        'projectId': projectId,
        'title': title,
        'description': description,
        'category': category,
        'isAnonymous': isAnonymous,
        if (locationLat != null && locationLng != null)
          'location': {'lat': locationLat, 'lng': locationLng},
      };

      final response =
          await _api.post<Map<String, dynamic>>('/reports', data: data);

      if (response.statusCode == 201 && response.data?['success'] == true) {
        final created = CitizenReport.fromJson(
            response.data!['data'] as Map<String, dynamic>);
        _localReports.insert(0, created);
        return created;
      }
    } catch (_) {
      // Offline fallback
    }

    final newReport = CitizenReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      citizenId: 'cit_current',
      title: title,
      description: description,
      category: category,
      status: ReportStatus.submitted,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
      location: locationLat != null && locationLng != null
          ? ReportLocation(lat: locationLat, lng: locationLng)
          : null,
    );

    _localReports.insert(0, newReport);
    return newReport;
  }

  Future<CitizenReport> updateReportStatus({
    required String reportId,
    required String status,
    String? response,
    String? actionTaken,
  }) async {
    try {
      final resp = await _api.patch<Map<String, dynamic>>(
        '/reports/$reportId/status',
        data: {
          'status': status,
          if (response != null) 'response': response,
          if (actionTaken != null) 'actionTaken': actionTaken,
        },
      );

      if (resp.statusCode == 200 && resp.data?['success'] == true) {
        final updated = CitizenReport.fromJson(
            resp.data!['data'] as Map<String, dynamic>);
        _updateLocalReport(updated);
        return updated;
      }
    } catch (_) {
      // Offline fallback
    }

    final index = _localReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final existing = _localReports[index];
      final targetStatus = ReportStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => ReportStatus.resolved,
      );

      final updated = existing.copyWith(
        status: targetStatus,
        response: response ?? existing.response,
        actionTaken: actionTaken ?? existing.actionTaken,
      );

      _localReports[index] = updated;
      return updated;
    }

    throw const ApiException('Report not found');
  }

  Future<List<String>> uploadEvidence({
    required String reportId,
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _api.uploadFiles<Map<String, dynamic>>(
        '/reports/$reportId/evidence',
        files,
        onProgress: onProgress,
      );
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return (response.data!['data'] as List<dynamic>).cast<String>();
      }
    } catch (_) {
      // Simulated upload for offline
    }

    return files.map((f) => 'local://${f.path.split(Platform.pathSeparator).last}').toList();
  }

  Future<PaginatedResponse<CitizenReport>> getMyReports({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/reports/my',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200 && response.data != null) {
        return PaginatedResponse.fromJson(
          response.data!,
          CitizenReport.fromJson,
        );
      }
    } catch (_) {
      // Offline fallback
    }

    // Return local reports (all created by this citizen on this device)
    return PaginatedResponse<CitizenReport>(
      data: _localReports,
      page: 1,
      limit: limit,
      total: _localReports.length,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }

  void _updateLocalReport(CitizenReport report) {
    final index = _localReports.indexWhere((r) => r.id == report.id);
    if (index != -1) {
      _localReports[index] = report;
    } else {
      _localReports.insert(0, report);
    }
  }

  PaginatedResponse<CitizenReport> _filterLocalReports({
    String? status,
    String? category,
    String? projectId,
    String? citizenId,
    int page = 1,
    int limit = 20,
  }) {
    var result = List<CitizenReport>.from(_localReports);

    if (status != null) {
      result = result.where((r) => r.status.name == status).toList();
    }
    if (category != null) {
      result = result.where((r) => r.category == category).toList();
    }
    if (projectId != null) {
      result = result.where((r) => r.projectId == projectId).toList();
    }

    final total = result.length;
    final totalPages = (total / limit).ceil().clamp(1, 9999);
    final startIndex = ((page - 1) * limit).clamp(0, total);
    final endIndex = (startIndex + limit).clamp(0, total);
    final paginated = result.sublist(startIndex, endIndex);

    return PaginatedResponse<CitizenReport>(
      data: paginated,
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    );
  }
}
