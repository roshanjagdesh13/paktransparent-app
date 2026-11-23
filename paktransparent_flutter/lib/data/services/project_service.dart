import 'package:dio/dio.dart';

import '../models/models.dart';
import '../data/sample_data.dart';
import '../../core/constants/app_constants.dart';
import 'api_service.dart';

/// Project service — handles network API requests with an offline-first
/// resilient repository to guarantee uninterrupted functionality.
class ProjectService {
  final ApiService _api;
  final List<Project> _localProjects = [];

  ProjectService({required ApiService apiService}) : _api = apiService {
    _localProjects.addAll(SampleData.initialProjects);
  }

  Future<PaginatedResponse<Project>> getProjects({
    ProjectFilters? filters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        ...?filters?.toQueryParams(),
      };

      final response = await _api.get<Map<String, dynamic>>(
        '/projects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return PaginatedResponse.fromJson(
          response.data!,
          Project.fromJson,
        );
      }
    } catch (_) {
      // Offline fallback: filter local repository
    }

    return _filterLocalProjects(filters: filters, page: page, limit: limit);
  }

  Future<Project> getProjectById(String id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/projects/$id');
      if (response.statusCode == 200 && response.data?['success'] == true) {
        return Project.fromJson(
            response.data!['data'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Offline fallback
    }

    final localMatch = _localProjects.where((p) => p.id == id).firstOrNull;
    if (localMatch != null) return localMatch;
    throw const ApiException('Project not found');
  }

  Future<Project> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/projects',
        data: projectData,
      );
      if (response.statusCode == 201 && response.data?['success'] == true) {
        final created = Project.fromJson(
            response.data!['data'] as Map<String, dynamic>);
        _localProjects.insert(0, created);
        return created;
      }
    } catch (_) {
      // Offline fallback: create locally
    }

    // Synthesize local project
    final id = 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final locationMap = projectData['location'] as Map<String, dynamic>?;
    final contractorMap = projectData['contractor'] as Map<String, dynamic>?;

    final newProject = Project(
      id: id,
      name: projectData['name'] as String? ?? 'Untitled Project',
      description: projectData['description'] as String? ?? '',
      category: ProjectCategory.values.firstWhere(
        (c) => c.name == projectData['category'],
        orElse: () => ProjectCategory.infrastructure,
      ),
      status: ProjectStatus.approved,
      province: Province.values.firstWhere(
        (p) => p.name == projectData['province'],
        orElse: () => Province.punjab,
      ),
      district: projectData['district'] as String? ?? 'General',
      budgetAllocated: (projectData['budgetAllocated'] as num?)?.toDouble() ?? 0.0,
      budgetReleased: (projectData['budgetReleased'] as num?)?.toDouble() ?? 0.0,
      budgetSpent: 0.0,
      budgetRemaining: (projectData['budgetAllocated'] as num?)?.toDouble() ?? 0.0,
      completionPercentage: 0,
      startDate: projectData['startDate'] != null ? DateTime.tryParse(projectData['startDate']) : DateTime.now(),
      expectedEndDate: projectData['expectedEndDate'] != null ? DateTime.tryParse(projectData['expectedEndDate']) : null,
      department: 'Ministry of Planning, Development & Special Initiatives',
      heroImage: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?w=1200',
      location: locationMap != null
          ? ProjectLocation(
              lat: (locationMap['lat'] as num?)?.toDouble() ?? 31.5204,
              lng: (locationMap['lng'] as num?)?.toDouble() ?? 74.3587,
              address: locationMap['address'] as String?,
            )
          : null,
      contractor: contractorMap != null
          ? Contractor(
              id: contractorMap['id'] as String? ?? 'c_new',
              name: contractorMap['name'] as String? ?? 'Apex Consortium',
              contactPerson: contractorMap['contactPerson'] as String?,
              phone: contractorMap['phone'] as String?,
            )
          : null,
      milestones: [
        Milestone(
          id: 'm1',
          title: 'Planning & Site Acquisition',
          status: 'completed',
          targetDate: DateTime.now(),
          order: 1,
        ),
        Milestone(
          id: 'm2',
          title: 'Foundation & Earthworks',
          status: 'in_progress',
          targetDate: DateTime.now().add(const Duration(days: 180)),
          order: 2,
        ),
      ],
    );

    _localProjects.insert(0, newProject);
    return newProject;
  }

  Future<Project> updateProject(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _api.put<Map<String, dynamic>>(
        '/projects/$id',
        data: updates,
      );
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final updated = Project.fromJson(
            response.data!['data'] as Map<String, dynamic>);
        _updateLocalProject(updated);
        return updated;
      }
    } catch (_) {
      // Offline fallback
    }

    final index = _localProjects.indexWhere((p) => p.id == id);
    if (index != -1) {
      final existing = _localProjects[index];
      final updated = existing.copyWith(
        name: updates['name'] as String?,
        description: updates['description'] as String?,
        completionPercentage: updates['completionPercentage'] as int?,
      );
      _localProjects[index] = updated;
      return updated;
    }

    throw const ApiException('Project not found');
  }

  Future<void> toggleFollowProject(String projectId) async {
    try {
      await _api.post<void>('/projects/$projectId/follow');
    } catch (_) {}

    final index = _localProjects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final p = _localProjects[index];
      _localProjects[index] = p.copyWith(
        isFollowed: !p.isFollowed,
        followersCount: p.isFollowed ? p.followersCount - 1 : p.followersCount + 1,
      );
    }
  }

  Future<void> toggleBookmarkProject(String projectId) async {
    try {
      await _api.post<void>('/projects/$projectId/bookmark');
    } catch (_) {}

    final index = _localProjects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final p = _localProjects[index];
      _localProjects[index] = p.copyWith(isBookmarked: !p.isBookmarked);
    }
  }

  void _updateLocalProject(Project project) {
    final index = _localProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _localProjects[index] = project;
    } else {
      _localProjects.insert(0, project);
    }
  }

  PaginatedResponse<Project> _filterLocalProjects({
    ProjectFilters? filters,
    int page = 1,
    int limit = 20,
  }) {
    var result = List<Project>.from(_localProjects);

    if (filters != null) {
      if (filters.search?.isNotEmpty == true) {
        final q = filters.search!.toLowerCase();
        result = result
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.district.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q))
            .toList();
      }
      if (filters.province != null) {
        result = result.where((p) => p.province == filters.province).toList();
      }
      if (filters.category != null) {
        result = result.where((p) => p.category == filters.category).toList();
      }
      if (filters.status != null) {
        result = result.where((p) => p.status == filters.status).toList();
      }
    }

    final total = result.length;
    final totalPages = (total / limit).ceil().clamp(1, 9999);
    final startIndex = ((page - 1) * limit).clamp(0, total);
    final endIndex = (startIndex + limit).clamp(0, total);
    final paginated = result.sublist(startIndex, endIndex);

    return PaginatedResponse<Project>(
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
