import { api, ApiResponse } from './api';
import type { User, UserRole } from '@/types';

/**
 * Authentication Service
 * Handles all authentication-related API calls
 */

interface LoginRequest {
  email: string;
  password: string;
  role: UserRole;
}

interface LoginResponse {
  user: User;
  token: string;
  refreshToken: string;
}

interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  cnic?: string;
  phone?: string;
  province?: string;
  district?: string;
  role: UserRole;
}

interface OTPVerifyRequest {
  email: string;
  otp: string;
}

export const authService = {
  /**
   * Login user
   */
  login: async (data: LoginRequest): Promise<ApiResponse<LoginResponse>> => {
    return api.post<LoginResponse>('/auth/login', data);
  },

  /**
   * Register new user
   */
  register: async (data: RegisterRequest): Promise<ApiResponse<User>> => {
    return api.post<User>('/auth/register', data);
  },

  /**
   * Verify OTP
   */
  verifyOTP: async (data: OTPVerifyRequest): Promise<ApiResponse<LoginResponse>> => {
    return api.post<LoginResponse>('/auth/verify-otp', data);
  },

  /**
   * Resend OTP
   */
  resendOTP: async (email: string): Promise<ApiResponse<{ message: string }>> => {
    return api.post<{ message: string }>('/auth/resend-otp', { email });
  },

  /**
   * Logout user
   */
  logout: async (): Promise<ApiResponse<void>> => {
    return api.post<void>('/auth/logout');
  },

  /**
   * Refresh access token
   */
  refreshToken: async (refreshToken: string): Promise<ApiResponse<{ token: string }>> => {
    return api.post<{ token: string }>('/auth/refresh', { refreshToken });
  },

  /**
   * Get current user profile
   */
  getProfile: async (): Promise<ApiResponse<User>> => {
    return api.get<User>('/auth/profile');
  },

  /**
   * Update user profile
   */
  updateProfile: async (data: Partial<User>): Promise<ApiResponse<User>> => {
    return api.put<User>('/auth/profile', data);
  },

  /**
   * Change password
   */
  changePassword: async (oldPassword: string, newPassword: string): Promise<ApiResponse<{ message: string }>> => {
    return api.post<{ message: string }>('/auth/change-password', {
      oldPassword,
      newPassword,
    });
  },

  /**
   * Request password reset
   */
  forgotPassword: async (email: string): Promise<ApiResponse<{ message: string }>> => {
    return api.post<{ message: string }>('/auth/forgot-password', { email });
  },

  /**
   * Reset password with token
   */
  resetPassword: async (token: string, newPassword: string): Promise<ApiResponse<{ message: string }>> => {
    return api.post<{ message: string }>('/auth/reset-password', {
      token,
      newPassword,
    });
  },
};
