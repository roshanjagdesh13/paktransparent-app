// New Workflow System Types

export type UserType = 'citizen' | 'government';

// All government roles (can be extended)
export type GovernmentRole =
  | 'prime_minister'
  | 'chief_minister'
  | 'governor'
  | 'federal_minister'
  | 'provincial_minister'
  | 'chief_secretary'
  | 'commissioner'
  | 'deputy_commissioner'
  | 'assistant_commissioner'
  | 'tehsildar'
  | 'department_head'
  | 'section_officer'
  | 'other';

// Submission authorities structure
export interface SubmissionAuthority {
  id: string;
  role: GovernmentRole;
  title: string;
  office: string;
  canReceiveFrom: GovernmentRole[];
}

// Document upload structure
export interface ProjectDocument {
  id: string;
  name: string;
  type: 'pdf' | 'docx' | 'xlsx' | 'image' | 'other';
  size: number; // in bytes
  url: string; // Data URL or actual URL
  uploadedBy: string;
  uploadedAt: Date;
  category: 'proposal' | 'budget' | 'technical' | 'environmental' | 'legal' | 'other';
}

// Project submission with dynamic routing
export interface ProjectSubmission {
  id: string;
  title: string;
  description: string;
  budget: number;
  category: string;
  province?: string;
  district?: string;
  location?: string;
  startDate?: Date;
  expectedEndDate?: Date;
  contractor?: string;
  estimatedBeneficiaries?: string;
  submittedBy: {
    userId: string;
    name: string;
    role: GovernmentRole | 'citizen';
    office?: string;
  };
  submittedTo: string[]; // Array of authority IDs
  submittedDate: Date;
  currentHolder: string; // Current authority ID
  status: ProjectStatus;
  approvalHistory: ApprovalAction[];
  comments: Comment[];
  documents: ProjectDocument[]; // Required documents
  priority: 'low' | 'medium' | 'high' | 'urgent';
  finalApprover?: string; // The authority who gave final approval
  approvedDate?: Date; // Date when finally approved
  publishedToCitizens?: boolean; // Whether visible on public dashboard
}

export type ProjectStatus =
  | 'draft' // Being prepared
  | 'pending_review' // Submitted, waiting for review
  | 'under_review' // Actively being reviewed
  | 'approved' // Final approval granted
  | 'rejected' // Rejected at any stage
  | 'revision_requested' // Needs changes
  | 'forwarded' // Forwarded to another authority
  | 'completed'; // Project execution completed

// Approval actions
export interface ApprovalAction {
  id: string;
  actionBy: {
    userId: string;
    name: string;
    role: GovernmentRole;
    office: string;
  };
  action: 'approve' | 'reject' | 'revise' | 'forward' | 'request_documents';
  forwardedTo?: string; // Authority ID if forwarded
  comments: string;
  timestamp: Date;
  documentsRequested?: string[]; // List of documents requested
  isFinalApproval?: boolean; // Whether this is the final approval
}

export interface Comment {
  id: string;
  userId: string;
  userName: string;
  userRole: GovernmentRole | 'citizen';
  text: string;
  timestamp: Date;
  isInternal: boolean; // Internal comment (not visible to citizen)
}

// Dashboard types
export interface IncomingRequest {
  projectId: string;
  project: ProjectSubmission;
  daysPending: number;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  requiresAction: boolean;
}

// Notification system
export interface Notification {
  id: string;
  userId: string;
  type: 'approval' | 'rejection' | 'comment' | 'forward' | 'status_update' | 'document_request' | 'submission';
  title: string;
  message: string;
  projectId?: string;
  read: boolean;
  timestamp: Date;
  actionRequired?: boolean; // Whether user needs to take action
}

// Authority hierarchy configuration
export interface AuthorityHierarchy {
  role: GovernmentRole;
  title: string;
  level: number; // 1 = highest (PM), 10 = lowest
  canSubmitTo: GovernmentRole[];
  canForwardTo: GovernmentRole[];
  department?: string;
}

// Available submission authorities based on current role
export const SUBMISSION_AUTHORITIES: Record<GovernmentRole | 'citizen', GovernmentRole[]> = {
  citizen: ['assistant_commissioner', 'deputy_commissioner', 'department_head', 'tehsildar'],
  tehsildar: ['assistant_commissioner', 'deputy_commissioner'],
  assistant_commissioner: ['deputy_commissioner', 'commissioner', 'department_head'],
  deputy_commissioner: ['commissioner', 'chief_secretary', 'department_head'],
  commissioner: ['chief_secretary', 'chief_minister'],
  department_head: ['chief_secretary', 'provincial_minister', 'federal_minister'],
  section_officer: ['department_head', 'deputy_commissioner'],
  chief_secretary: ['chief_minister', 'governor'],
  provincial_minister: ['chief_minister', 'federal_minister'],
  chief_minister: ['prime_minister', 'federal_minister', 'governor'],
  federal_minister: ['prime_minister'],
  governor: ['prime_minister'],
  prime_minister: [], // PM is highest authority
  other: ['deputy_commissioner', 'commissioner', 'department_head'],
};

// Role display information
export const ROLE_INFO: Record<GovernmentRole, { title: string; office: string; description: string }> = {
  prime_minister: {
    title: 'Prime Minister',
    office: 'Office of the Prime Minister',
    description: 'Highest executive authority of Pakistan',
  },
  chief_minister: {
    title: 'Chief Minister',
    office: 'Chief Minister Office',
    description: 'Head of provincial government',
  },
  governor: {
    title: 'Governor',
    office: 'Governor House',
    description: 'Constitutional head of province',
  },
  federal_minister: {
    title: 'Federal Minister',
    office: 'Federal Ministry',
    description: 'Federal cabinet member',
  },
  provincial_minister: {
    title: 'Provincial Minister',
    office: 'Provincial Ministry',
    description: 'Provincial cabinet member',
  },
  chief_secretary: {
    title: 'Chief Secretary',
    office: 'Provincial Secretariat',
    description: 'Administrative head of province',
  },
  commissioner: {
    title: 'Commissioner',
    office: 'Commissioner Office',
    description: 'Divisional coordinator',
  },
  deputy_commissioner: {
    title: 'Deputy Commissioner',
    office: 'DC Office',
    description: 'District administrative head',
  },
  assistant_commissioner: {
    title: 'Assistant Commissioner',
    office: 'AC Office',
    description: 'Tehsil administrative officer',
  },
  tehsildar: {
    title: 'Tehsildar',
    office: 'Tehsil Office',
    description: 'Revenue officer',
  },
  department_head: {
    title: 'Department Head',
    office: 'Department Office',
    description: 'Head of government department',
  },
  section_officer: {
    title: 'Section Officer',
    office: 'Section Office',
    description: 'Section administrative officer',
  },
  other: {
    title: 'Government Official',
    office: 'Government Office',
    description: 'Other government role',
  },
};
