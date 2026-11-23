import { api, ApiResponse, PaginatedResponse } from './api';
import type { Project, ProjectFilters } from '@/types';

/**
 * Project Service - Handles all project-related API calls
 */
export const projectService = {
  /**
   * Get all projects with optional filters
   */
  getProjects: async (
    filters?: ProjectFilters,
    page: number = 1,
    limit: number = 20
  ): Promise<PaginatedResponse<Project>> => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('limit', limit.toString());

    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          params.append(key, String(value));
        }
      });
    }

    // Mock response - Replace with actual API call
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          data: [],
          pagination: {
            page,
            limit,
            total: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
          },
        });
      }, 500);
    });
  },

  /**
   * Get project by ID
   */
  getProjectById: async (id: string): Promise<ApiResponse<Project>> => {
    return api.get<Project>(`/projects/${id}`);
  },

  /**
   * Create new project
   */
  createProject: async (projectData: Partial<Project>): Promise<ApiResponse<Project>> => {
    return api.post<Project>('/projects', projectData);
  },

  /**
   * Update project
   */
  updateProject: async (id: string, projectData: Partial<Project>): Promise<ApiResponse<Project>> => {
    return api.put<Project>(`/projects/${id}`, projectData);
  },

  /**
   * Delete project
   */
  deleteProject: async (id: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/projects/${id}`);
  },

  /**
   * Follow/Unfollow project
   */
  toggleFollowProject: async (projectId: string): Promise<ApiResponse<{ isFollowing: boolean }>> => {
    return api.post<{ isFollowing: boolean }>(`/projects/${projectId}/follow`);
  },

  /**
   * Bookmark/Unbookmark project
   */
  toggleBookmarkProject: async (projectId: string): Promise<ApiResponse<{ isBookmarked: boolean }>> => {
    return api.post<{ isBookmarked: boolean }>(`/projects/${projectId}/bookmark`);
  },

  /**
   * Upload project media
   */
  uploadProjectMedia: async (
    projectId: string,
    files: File[],
    onProgress?: (progress: number) => void
  ): Promise<ApiResponse<string[]>> => {
    return api.uploadMultiple<string[]>(`/projects/${projectId}/media`, files, onProgress);
  },

  /**
   * Upload project documents
   */
  uploadProjectDocuments: async (
    projectId: string,
    files: File[],
    onProgress?: (progress: number) => void
  ): Promise<ApiResponse<string[]>> => {
    return api.uploadMultiple<string[]>(`/projects/${projectId}/documents`, files, onProgress);
  },
};
