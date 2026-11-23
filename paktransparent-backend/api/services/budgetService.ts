import { api, ApiResponse } from './api';
import type { BudgetOverview } from '@/types';

/**
 * Budget Service
 * Handles all budget-related API calls
 */

export const budgetService = {
  /**
   * Get overall budget overview
   */
  getOverview: async (fiscalYear?: string): Promise<ApiResponse<BudgetOverview>> => {
    const params = fiscalYear ? `?fiscalYear=${fiscalYear}` : '';
    return api.get<BudgetOverview>(`/budget/overview${params}`);
  },

  /**
   * Get budget by province
   */
  getProvinceBreakdown: async (fiscalYear?: string): Promise<ApiResponse<any>> => {
    const params = fiscalYear ? `?fiscalYear=${fiscalYear}` : '';
    return api.get(`/budget/provinces${params}`);
  },

  /**
   * Get budget by category
   */
  getCategoryBreakdown: async (fiscalYear?: string): Promise<ApiResponse<any>> => {
    const params = fiscalYear ? `?fiscalYear=${fiscalYear}` : '';
    return api.get(`/budget/categories${params}`);
  },

  /**
   * Get budget by department
   */
  getDepartmentBreakdown: async (fiscalYear?: string): Promise<ApiResponse<any>> => {
    const params = fiscalYear ? `?fiscalYear=${fiscalYear}` : '';
    return api.get(`/budget/departments${params}`);
  },

  /**
   * Get budget trends over time
   */
  getTrends: async (
    startYear: string,
    endYear: string,
    groupBy: 'month' | 'quarter' | 'year' = 'month'
  ): Promise<ApiResponse<any>> => {
    return api.get(`/budget/trends?start=${startYear}&end=${endYear}&groupBy=${groupBy}`);
  },

  /**
   * Get budget comparison
   */
  getComparison: async (year1: string, year2: string): Promise<ApiResponse<any>> => {
    return api.get(`/budget/compare?year1=${year1}&year2=${year2}`);
  },

  /**
   * Allocate budget (government only)
   */
  allocateBudget: async (data: {
    projectId: string;
    amount: number;
    fiscalYear: string;
    category: string;
    department: string;
  }): Promise<ApiResponse<any>> => {
    return api.post('/budget/allocate', data);
  },

  /**
   * Release budget (government only)
   */
  releaseBudget: async (data: {
    projectId: string;
    amount: number;
    releaseDate: Date;
    approvedBy: string;
  }): Promise<ApiResponse<any>> => {
    return api.post('/budget/release', data);
  },

  /**
   * Get budget alerts
   */
  getAlerts: async (): Promise<ApiResponse<any[]>> => {
    return api.get('/budget/alerts');
  },
};
