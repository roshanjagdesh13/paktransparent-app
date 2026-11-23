import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';

/// Project state provider — manages project browsing, filtering, and details.
class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService;

  List<Project> _projects = [];
  Project? _selectedProject;
  ProjectFilters _filters = const ProjectFilters();
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;

  ProjectProvider({required ProjectService projectService})
      : _projectService = projectService;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  ProjectFilters get filters => _filters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // ─── Load Projects ─────────────────────────────────────────────────────────
  Future<void> loadProjects({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _projects.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _projectService.getProjects(
        filters: _filters,
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _projects = response.data;
      } else {
        _projects.addAll(response.data);
      }

      _totalPages = response.totalPages;
      _hasMore = response.hasNext;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await loadProjects();
    }
  }

  // ─── Load Project Details ──────────────────────────────────────────────────
  Future<void> loadProjectDetails(String projectId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProject = await _projectService.getProjectById(projectId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }

  // ─── Filters ───────────────────────────────────────────────────────────────
  Future<void> applyFilters(ProjectFilters filters) async {
    _filters = filters;
    await loadProjects(refresh: true);
  }

  Future<void> clearFilters() async {
    _filters = const ProjectFilters();
    await loadProjects(refresh: true);
  }

  Future<void> searchProjects(String query) async {
    _filters = _filters.copyWith(search: query);
    await loadProjects(refresh: true);
  }

  Future<void> filterByProvince(Province province) async {
    _filters = _filters.copyWith(province: province);
    await loadProjects(refresh: true);
  }

  Future<void> filterByCategory(ProjectCategory category) async {
    _filters = _filters.copyWith(category: category);
    await loadProjects(refresh: true);
  }

  Future<void> filterByStatus(ProjectStatus status) async {
    _filters = _filters.copyWith(status: status);
    await loadProjects(refresh: true);
  }

  // ─── Create Project (Government) ───────────────────────────────────────────
  Future<Project> createProject(Map<String, dynamic> projectData) async {
    _setLoading(true);
    _clearError();

    try {
      final project = await _projectService.createProject(projectData);
      // Add to beginning of list
      _projects.insert(0, project);
      notifyListeners();
      return project;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Update Project (Government) ───────────────────────────────────────────
  Future<Project> updateProject(
      String projectId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updated = await _projectService.updateProject(projectId, updates);
      
      // Update in list
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = updated;
      }
      
      // Update selected project if it's the same
      if (_selectedProject?.id == projectId) {
        _selectedProject = updated;
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

  // ─── Follow/Bookmark ───────────────────────────────────────────────────────
  Future<void> toggleFollow(String projectId) async {
    try {
      await _projectService.toggleFollowProject(projectId);
      // In a real app, update the project's follower count
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
    }
  }

  Future<void> toggleBookmark(String projectId) async {
    try {
      await _projectService.toggleBookmarkProject(projectId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
    }
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
