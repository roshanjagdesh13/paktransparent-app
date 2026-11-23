// Government Hierarchy and Role Types
// NOTE: This file is deprecated. Use types from workflow.ts instead.
// Kept for backward compatibility only.

import type { GovernmentRole } from './workflow';
export type { GovernmentRole } from './workflow';

// Old type kept for compatibility
export type ApprovalLevel = 1 | 2 | 3 | 4 | 5;

export interface GovernmentHierarchy {
  role: GovernmentRole;
  level: ApprovalLevel; // 1 = highest (PM), 5 = lowest (Clerk)
  title: string;
  canApproveUpTo: number; // Maximum budget they can approve (in PKR)
  canCreateProjects: boolean;
  canApproveProjects: boolean;
  canAssignTasks: boolean;
  canEscalate: boolean;
  reportsTo?: GovernmentRole;
  canViewNational: boolean;
  canViewProvincial: boolean;
  canViewDistrict: boolean;
}

export const GOVERNMENT_HIERARCHY: Partial<Record<GovernmentRole, GovernmentHierarchy>> = {
  prime_minister: {
    role: 'prime_minister',
    level: 1,
    title: 'Prime Minister of Pakistan',
    canApproveUpTo: Infinity,
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: false,
    canViewNational: true,
    canViewProvincial: true,
    canViewDistrict: true,
  },
  chief_minister: {
    role: 'chief_minister',
    level: 2,
    title: 'Chief Minister',
    canApproveUpTo: 50000000000, // 50 billion
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: 'prime_minister',
    canViewNational: false,
    canViewProvincial: true,
    canViewDistrict: true,
  },
  deputy_commissioner: {
    role: 'deputy_commissioner',
    level: 4,
    title: 'Deputy Commissioner',
    canApproveUpTo: 2000000000, // 2 billion
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: 'commissioner',
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  },
  assistant_commissioner: {
    role: 'assistant_commissioner',
    level: 4,
    title: 'Assistant Commissioner',
    canApproveUpTo: 500000000, // 500 million
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: false,
    canEscalate: true,
    reportsTo: 'deputy_commissioner',
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  },
  department_head: {
    role: 'department_head',
    level: 4,
    title: 'Department Head',
    canApproveUpTo: 1000000000, // 1 billion
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: 'chief_secretary',
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  },
  section_officer: {
    role: 'section_officer',
    level: 5,
    title: 'Section Officer',
    canApproveUpTo: 100000000, // 100 million
    canCreateProjects: false,
    canApproveProjects: false,
    canAssignTasks: false,
    canEscalate: true,
    reportsTo: 'department_head',
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  },
};

export interface ApprovalWorkflow {
  id: string;
  projectId: string;
  projectName: string;
  projectBudget: number;
  requiredApprovalLevel: ApprovalLevel;
  currentApprovalLevel: ApprovalLevel;
  status: 'pending' | 'approved' | 'rejected' | 'escalated';
  submittedBy: {
    userId: string;
    role: GovernmentRole;
    name: string;
  };
  approvalChain: ApprovalStep[];
  createdAt: Date;
  updatedAt: Date;
}

export interface ApprovalStep {
  id: string;
  approverRole: GovernmentRole;
  approverName?: string;
  approverId?: string;
  status: 'pending' | 'approved' | 'rejected' | 'escalated';
  comments?: string;
  timestamp?: Date;
  level: ApprovalLevel;
}

export interface TaskAssignment {
  id: string;
  title: string;
  description: string;
  assignedBy: {
    userId: string;
    role: GovernmentRole;
    name: string;
  };
  assignedTo: {
    userId: string;
    role: GovernmentRole;
    name: string;
  };
  priority: 'critical' | 'high' | 'medium' | 'low';
  status: 'pending' | 'in_progress' | 'completed' | 'overdue';
  dueDate: Date;
  createdAt: Date;
  relatedProjectId?: string;
}

export interface PriorityIssue {
  id: string;
  title: string;
  description: string;
  type: 'project_delay' | 'budget_overrun' | 'citizen_complaint' | 'emergency' | 'policy_matter';
  severity: 'critical' | 'high' | 'medium' | 'low';
  affectedArea: {
    province?: string;
    district?: string;
    national?: boolean;
  };
  requiresAttentionFrom: ApprovalLevel;
  status: 'new' | 'under_review' | 'resolved' | 'escalated';
  createdAt: Date;
  relatedProjectId?: string;
  relatedReportId?: string;
}

// Helper function to determine required approval level based on budget
export const getRequiredApprovalLevel = (budget: number): ApprovalLevel => {
  if (budget >= 50000000000) return 1; // PM level (50B+)
  if (budget >= 10000000000) return 2; // CM/Minister level (10B-50B)
  if (budget >= 2000000000) return 3; // Secretary/DC level (2B-10B)
  if (budget >= 500000000) return 4; // Deputy/Assistant level (500M-2B)
  return 5; // Section Officer level (<500M)
};

// Helper function to check if user can approve a project
export const canUserApproveProject = (
  userRole: GovernmentRole,
  projectBudget: number
): { canApprove: boolean; reason?: string; escalateTo?: GovernmentRole } => {
  const hierarchy = GOVERNMENT_HIERARCHY[userRole];
  
  if (!hierarchy) {
    return {
      canApprove: false,
      reason: 'Role hierarchy not found',
    };
  }
  
  if (!hierarchy.canApproveProjects) {
    return {
      canApprove: false,
      reason: 'Your role does not have project approval authority',
      escalateTo: hierarchy.reportsTo,
    };
  }

  if (projectBudget > hierarchy.canApproveUpTo) {
    return {
      canApprove: false,
      reason: `This project budget (${projectBudget.toLocaleString()}) exceeds your approval limit (${hierarchy.canApproveUpTo.toLocaleString()})`,
      escalateTo: hierarchy.reportsTo,
    };
  }

  return { canApprove: true };
};

// Helper to get approval chain for a project
export const getApprovalChain = (projectBudget: number): GovernmentRole[] => {
  const requiredLevel = getRequiredApprovalLevel(projectBudget);
  const chain: GovernmentRole[] = [];

  // Find roles that match the required level
  Object.entries(GOVERNMENT_HIERARCHY).forEach(([role, hierarchy]) => {
    if (hierarchy && hierarchy.level <= requiredLevel && hierarchy.canApproveProjects) {
      chain.push(role as GovernmentRole);
    }
  });

  // Sort by level (highest authority first)
  return chain.sort((a, b) => {
    const aHierarchy = GOVERNMENT_HIERARCHY[a];
    const bHierarchy = GOVERNMENT_HIERARCHY[b];
    if (!aHierarchy || !bHierarchy) return 0;
    return aHierarchy.level - bHierarchy.level;
  });
};
