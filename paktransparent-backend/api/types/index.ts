// Core Types for PakTransparent Platform

import { GovernmentRole } from './government';

export type UserRole = 'citizen' | 'government' | 'admin' | 'contractor';

export type ProjectStatus = 'pending' | 'approved' | 'in_progress' | 'completed' | 'suspended' | 'cancelled' | 'requires_approval';

export type ReportStatus = 'submitted' | 'under_review' | 'resolved' | 'rejected';

export type Province = 'punjab' | 'sindh' | 'kpk' | 'balochistan' | 'gilgit_baltistan' | 'azad_kashmir';

export type ProjectCategory = 'infrastructure' | 'education' | 'healthcare' | 'transport' | 'energy' | 'water' | 'agriculture' | 'defense' | 'social_welfare' | 'other';

// User Types
export interface User {
  id: string;
  email: string;
  cnic?: string;
  name: string;
  role: UserRole;
  // Government-specific fields
  governmentRole?: GovernmentRole;
  employeeCode?: string;
  designation?: string;
  approvalAuthority?: number; // Max budget they can approve
  avatar?: string;
  phone?: string;
  province?: Province;
  district?: string;
  department?: string;
  isVerified: boolean;
  createdAt: Date;
  lastLogin?: Date;
}

// Project Types
export interface Project {
  id: string;
  projectId: string; // e.g., "NHA-2021-BR-009"
  name: string;
  description: string;
  category: ProjectCategory;
  status: ProjectStatus;
  
  // Location
  province: Province;
  district: string;
  location: {
    lat: number;
    lng: number;
    address: string;
  };
  
  // Financial
  budgetAllocated: number;
  budgetReleased: number;
  budgetSpent: number;
  budgetRemaining: number;
  currency: string; // 'PKR'
  
  // Timeline
  startDate: Date;
  expectedEndDate: Date;
  actualEndDate?: Date;
  completionPercentage: number;
  
  // Stakeholders
  department: string;
  contractor?: {
    id: string;
    name: string;
    contactPerson: string;
    phone: string;
  };
  engineer?: string;
  consultant?: string;
  
  // Media & Documents
  heroImage?: string;
  images: string[];
  videos: string[];
  documents: Document[];
  
  // Milestones
  milestones: Milestone[];
  
  // Engagement
  followers: number;
  viewCount: number;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
}

export interface Milestone {
  id: string;
  title: string;
  description?: string;
  status: 'completed' | 'in_progress' | 'pending';
  targetDate: Date;
  completedDate?: Date;
  order: number;
}

export interface Document {
  id: string;
  name: string;
  type: 'pdf' | 'docx' | 'xlsx' | 'pptx' | 'image' | 'video' | 'other';
  url: string;
  size: number; // in bytes
  uploadedBy: string;
  uploadedAt: Date;
  category: 'contract' | 'audit' | 'inspection' | 'invoice' | 'receipt' | 'report' | 'tender' | 'other';
  isPublic: boolean;
}

// Citizen Report Types
export interface CitizenReport {
  id: string;
  projectId: string;
  citizenId: string;
  citizenName?: string; // Optional for anonymous reports
  
  title: string;
  description: string;
  category: 'delay' | 'quality' | 'corruption' | 'mismanagement' | 'safety' | 'environmental' | 'other';
  
  evidence: {
    images: string[];
    videos: string[];
    documents: string[];
  };
  
  location?: {
    lat: number;
    lng: number;
  };
  
  status: ReportStatus;
  priority: 'low' | 'medium' | 'high' | 'critical';
  
  isAnonymous: boolean;
  
  governmentResponse?: {
    respondedBy: string;
    respondedAt: Date;
    response: string;
    actionTaken?: string;
  };
  
  createdAt: Date;
  updatedAt: Date;
}

// Budget Analytics Types
export interface BudgetOverview {
  fiscalYear: string;
  totalAllocated: number;
  totalSpent: number;
  totalRemaining: number;
  utilizationPercentage: number;
  
  byProvince: ProvinceBreakdown[];
  byCategory: CategoryBreakdown[];
  byDepartment: DepartmentBreakdown[];
}

export interface ProvinceBreakdown {
  province: Province;
  allocated: number;
  spent: number;
  projectCount: number;
  utilizationRate: number;
}

export interface CategoryBreakdown {
  category: ProjectCategory;
  allocated: number;
  spent: number;
  projectCount: number;
}

export interface DepartmentBreakdown {
  department: string;
  allocated: number;
  spent: number;
  projectCount: number;
}

// Notification Types
export interface Notification {
  id: string;
  userId: string;
  type: 'project_update' | 'report_response' | 'milestone_completed' | 'budget_alert' | 'system';
  title: string;
  message: string;
  data?: Record<string, unknown>;
  isRead: boolean;
  createdAt: Date;
}

// Upload Types
export interface UploadProgress {
  fileName: string;
  progress: number;
  status: 'pending' | 'uploading' | 'completed' | 'error';
  error?: string;
}

// Filter & Search Types
export interface ProjectFilters {
  search?: string;
  province?: Province | Province[];
  district?: string[];
  category?: ProjectCategory | ProjectCategory[];
  status?: ProjectStatus | ProjectStatus[];
  budgetMin?: number;
  budgetMax?: number;
  dateFrom?: Date;
  dateTo?: Date;
  sortBy?: 'budget' | 'date' | 'completion' | 'name';
  sortOrder?: 'asc' | 'desc';
}

// Audit Trail Types
export interface AuditEntry {
  id: string;
  projectId: string;
  action: 'created' | 'updated' | 'budget_released' | 'milestone_completed' | 'document_uploaded' | 'status_changed';
  performedBy: string;
  performedByRole: UserRole;
  details: string;
  changes?: Record<string, { old: unknown; new: unknown }>;
  timestamp: Date;
  ipAddress?: string;
}

// Contractor Types
export interface Contractor {
  id: string;
  name: string;
  registrationNumber: string;
  contactPerson: string;
  email: string;
  phone: string;
  address: string;
  
  specializations: string[];
  
  activeProjects: number;
  completedProjects: number;
  totalValueDelivered: number;
  
  rating: number; // 0-5
  reviews: number;
  
  verificationStatus: 'verified' | 'pending' | 'rejected';
  
  documents: Document[];
  
  createdAt: Date;
}

// Dashboard Stats Types
export interface DashboardStats {
  totalProjects: number;
  activeProjects: number;
  completedProjects: number;
  totalBudget: number;
  spentBudget: number;
  pendingReports: number;
  resolvedReports: number;
  citizenEngagement: number;
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: Date;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrevious: boolean;
  };
}
