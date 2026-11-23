import { api, ApiResponse, PaginatedResponse } from './api';
import type { CitizenReport } from '@/types';

/**
 * Report Service
 * Handles all citizen report-related API calls
 */

interface CreateReportRequest {
  projectId: string;
  title: string;
  description: string;
  category: string;
  evidence?: {
    images?: string[];
    videos?: string[];
    documents?: string[];
  };
  location?: {
    lat: number;
    lng: number;
  };
  isAnonymous: boolean;
}

interface UpdateReportStatusRequest {
  status: 'under_review' | 'resolved' | 'rejected';
  response?: string;
  actionTaken?: string;
}

export const reportService = {
  /**
   * Get all reports (with filters)
   */
  getReports: async (
    filters?: {
      status?: string;
      category?: string;
      projectId?: string;
      citizenId?: string;
    },
    page: number = 1,
    limit: number = 20
  ): Promise<PaginatedResponse<CitizenReport>> => {
    const params = new URLSearchParams();
    params.append('page', page.toString());
    params.append('limit', limit.toString());

    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, String(value));
      });
    }

    return api.get<PaginatedResponse<CitizenReport>>(`/reports?${params.toString()}`);
  },

  /**
   * Get report by ID
   */
  getReportById: async (id: string): Promise<ApiResponse<CitizenReport>> => {
    return api.get<CitizenReport>(`/reports/${id}`);
  },

  /**
   * Create new report
   */
  createReport: async (data: CreateReportRequest): Promise<ApiResponse<CitizenReport>> => {
    return api.post<CitizenReport>('/reports', data);
  },

  /**
   * Update report (citizen can update before review)
   */
  updateReport: async (id: string, data: Partial<CreateReportRequest>): Promise<ApiResponse<CitizenReport>> => {
    return api.put<CitizenReport>(`/reports/${id}`, data);
  },

  /**
   * Delete report (only before review)
   */
  deleteReport: async (id: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/reports/${id}`);
  },

  /**
   * Update report status (government only)
   */
  updateReportStatus: async (
    id: string,
    data: UpdateReportStatusRequest
  ): Promise<ApiResponse<CitizenReport>> => {
    return api.patch<CitizenReport>(`/reports/${id}/status`, data);
  },

  /**
   * Upload report evidence
   */
  uploadEvidence: async (
    reportId: string,
    files: File[],
    onProgress?: (progress: number) => void
  ): Promise<ApiResponse<string[]>> => {
    return api.uploadMultiple<string[]>(`/reports/${reportId}/evidence`, files, onProgress);
  },

  /**
   * Get reports by project
   */
  getProjectReports: async (
    projectId: string,
    page: number = 1,
    limit: number = 20
  ): Promise<PaginatedResponse<CitizenReport>> => {
    return api.get<PaginatedResponse<CitizenReport>>(
      `/projects/${projectId}/reports?page=${page}&limit=${limit}`
    );
  },

  /**
   * Get my reports (citizen)
   */
  getMyReports: async (
    page: number = 1,
    limit: number = 20
  ): Promise<PaginatedResponse<CitizenReport>> => {
    return api.get<PaginatedResponse<CitizenReport>>(`/reports/my?page=${page}&limit=${limit}`);
  },

  /**
   * Get report statistics
   */
  getReportStats: async (): Promise<ApiResponse<{
    total: number;
    byStatus: Record<string, number>;
    byCategory: Record<string, number>;
    resolutionRate: number;
  }>> => {
    return api.get('/reports/stats');
  },
};
