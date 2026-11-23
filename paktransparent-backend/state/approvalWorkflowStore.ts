import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import {
  ProjectSubmission,
  ApprovalAction,
  Comment,
  Notification,
  GovernmentRole,
  ProjectStatus,
  ProjectDocument,
} from '@/types/workflow';
import { Project } from '@/types';

interface ApprovalWorkflowState {
  projects: ProjectSubmission[];
  notifications: Notification[];
  isLoading: boolean;

  // Actions
  submitProject: (project: Omit<ProjectSubmission, 'id' | 'submittedDate' | 'status' | 'approvalHistory' | 'comments' | 'publishedToCitizens'>) => Promise<string>;
  approveProject: (projectId: string, userId: string, userName: string, userRole: GovernmentRole, office: string, comments: string, isFinalApproval?: boolean) => Promise<void>;
  rejectProject: (projectId: string, userId: string, userName: string, userRole: GovernmentRole, office: string, comments: string) => Promise<void>;
  requestRevision: (projectId: string, userId: string, userName: string, userRole: GovernmentRole, office: string, comments: string) => Promise<void>;
  forwardProject: (projectId: string, userId: string, userName: string, userRole: GovernmentRole, office: string, forwardTo: string, comments: string) => Promise<void>;
  requestDocuments: (projectId: string, userId: string, userName: string, userRole: GovernmentRole, office: string, documentsNeeded: string[], comments: string) => Promise<void>;
  uploadDocument: (projectId: string, document: Omit<ProjectDocument, 'id' | 'uploadedAt'>) => Promise<void>;
  addComment: (projectId: string, userId: string, userName: string, userRole: GovernmentRole | 'citizen', text: string, isInternal: boolean) => Promise<void>;
  
  // Queries
  getIncomingRequests: (userId: string, userRole: GovernmentRole) => ProjectSubmission[];
  getMySubmissions: (userId: string) => ProjectSubmission[];
  getProjectById: (projectId: string) => ProjectSubmission | undefined;
  getNotifications: (userId: string, userRole: GovernmentRole) => Notification[];
  getApprovedProjects: () => ProjectSubmission[]; // Get all approved projects
  markNotificationRead: (notificationId: string) => void;
  markAllNotificationsRead: (userId: string, userRole: GovernmentRole) => void;
}

// Helper function to convert ProjectSubmission to public Project
const convertToPublicProject = (submission: ProjectSubmission): Project => {
  return {
    id: submission.id,
    projectId: `${submission.category.toUpperCase()}-${new Date(submission.submittedDate).getFullYear()}-${submission.id.substring(0, 8)}`,
    name: submission.title,
    description: submission.description,
    category: submission.category as any,
    status: 'approved' as any,
    province: submission.province as any || 'punjab',
    district: submission.district || 'Unknown',
    location: {
      lat: 31.5204,
      lng: 74.3587,
      address: submission.location || 'Pakistan',
    },
    budgetAllocated: submission.budget,
    budgetReleased: 0,
    budgetSpent: 0,
    budgetRemaining: submission.budget,
    currency: 'PKR',
    startDate: submission.startDate || new Date(),
    expectedEndDate: submission.expectedEndDate || new Date(),
    completionPercentage: 0,
    department: submission.submittedBy.office || 'Government Department',
    contractor: submission.contractor ? {
      id: 'contractor_' + Date.now(),
      name: submission.contractor,
      contactPerson: 'Contact Person',
      phone: '+92-300-0000000',
    } : undefined,
    heroImage: undefined,
    images: [],
    videos: [],
    documents: submission.documents.map(doc => ({
      id: doc.id,
      name: doc.name,
      type: doc.type as any,
      url: doc.url,
      size: doc.size,
      uploadedBy: doc.uploadedBy,
      uploadedAt: doc.uploadedAt,
      category: doc.category as any,
      isPublic: true,
    })),
    milestones: [],
    followers: 0,
    viewCount: 0,
    createdAt: submission.submittedDate,
    updatedAt: new Date(),
    createdBy: submission.submittedBy.userId,
  };
};

// Helper function to publish project to citizen dashboard
const publishProjectToCitizens = (submission: ProjectSubmission) => {
  try {
    // Get existing projects from localStorage
    const savedProjects = localStorage.getItem('government_projects');
    const existingProjects: Project[] = savedProjects ? JSON.parse(savedProjects) : [];
    
    // Check if project already published
    const alreadyPublished = existingProjects.some(p => p.id === submission.id);
    if (alreadyPublished) {
      console.log('Project already published:', submission.id);
      return;
    }
    
    // Convert and add to citizen projects
    const publicProject = convertToPublicProject(submission);
    existingProjects.push(publicProject);
    
    // Save back to localStorage
    localStorage.setItem('government_projects', JSON.stringify(existingProjects));
    
    console.log('✅ Project published to citizen dashboard:', submission.title);
  } catch (error) {
    console.error('Error publishing project to citizens:', error);
  }
};

export const useApprovalWorkflowStore = create<ApprovalWorkflowState>()(
  persist(
    (set, get) => ({
      projects: [],
      notifications: [],
      isLoading: false,

      submitProject: async (projectData) => {
        const projectId = `proj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        const newProject: ProjectSubmission = {
          ...projectData,
          id: projectId,
          submittedDate: new Date(),
          status: 'pending_review',
          approvalHistory: [],
          comments: [],
          publishedToCitizens: false,
        };

        set((state) => ({
          projects: [...state.projects, newProject],
        }));

        // Create notifications for all submitted authorities
        const submitterIdentifier = projectData.submittedBy.role !== 'citizen' 
          ? projectData.submittedBy.role 
          : projectData.submittedBy.userId;

        const notifications: Notification[] = [
          // Notification for submitter
          {
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: submitterIdentifier,
            type: 'submission',
            title: 'Project Submitted Successfully ✅',
            message: `Your project "${projectData.title}" has been submitted for review`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: false,
          },
          // Notifications for all authorities
          ...projectData.submittedTo.map((authorityId) => ({
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: authorityId,
            type: 'submission' as const,
            title: 'New Project Awaiting Review 📬',
            message: `${projectData.submittedBy.name} submitted "${projectData.title}" for your review`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: true,
          })),
        ];

        set((state) => ({
          notifications: [...state.notifications, ...notifications],
        }));

        return projectId;
      },

      approveProject: async (projectId, userId, userName, userRole, office, comments, isFinalApproval = true) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const approvalAction: ApprovalAction = {
            id: `action_${Date.now()}`,
            actionBy: { userId, name: userName, role: userRole, office },
            action: 'approve',
            comments,
            timestamp: new Date(),
            isFinalApproval,
          };

          const updatedProject: ProjectSubmission = {
            ...project,
            status: 'approved',
            approvalHistory: [...project.approvalHistory, approvalAction],
            finalApprover: userRole,
            approvedDate: new Date(),
            publishedToCitizens: false, // Will be set to true when published
          };

          // If final approval, publish to citizens
          if (isFinalApproval) {
            publishProjectToCitizens(updatedProject);
            updatedProject.publishedToCitizens = true;
          }

          // Create notification for submitter - use their role if they're government
          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;

          const notification: Notification = {
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: submitterIdentifier,
            type: 'approval',
            title: isFinalApproval ? 'Project Finally Approved! 🎉' : 'Project Approved ✅',
            message: isFinalApproval 
              ? `${userName} (${office}) gave final approval to your project "${project.title}". It is now visible to citizens!`
              : `${userName} (${office}) approved your project "${project.title}"`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: false,
          };

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, notification],
          };
        });
      },

      rejectProject: async (projectId, userId, userName, userRole, office, comments) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const approvalAction: ApprovalAction = {
            id: `action_${Date.now()}`,
            actionBy: { userId, name: userName, role: userRole, office },
            action: 'reject',
            comments,
            timestamp: new Date(),
          };

          const updatedProject: ProjectSubmission = {
            ...project,
            status: 'rejected',
            approvalHistory: [...project.approvalHistory, approvalAction],
          };

          // Create notification for submitter - use their role if they're government
          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;

          const notification: Notification = {
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: submitterIdentifier,
            type: 'rejection',
            title: 'Project Rejected ❌',
            message: `${userName} (${office}) rejected your project "${project.title}". Reason: ${comments}`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: false,
          };

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, notification],
          };
        });
      },

      requestRevision: async (projectId, userId, userName, userRole, office, comments) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const approvalAction: ApprovalAction = {
            id: `action_${Date.now()}`,
            actionBy: { userId, name: userName, role: userRole, office },
            action: 'revise',
            comments,
            timestamp: new Date(),
          };

          // Create notification for submitter - use their role if they're government
          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;

          const updatedProject: ProjectSubmission = {
            ...project,
            status: 'revision_requested',
            approvalHistory: [...project.approvalHistory, approvalAction],
            currentHolder: submitterIdentifier, // Send back to submitter using their role/id
          };

          // Create notification for submitter
          const notification: Notification = {
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: submitterIdentifier,
            type: 'status_update',
            title: 'Revision Requested 🔄',
            message: `${userName} (${office}) requested revisions for "${project.title}". Comments: ${comments}`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: true,
          };

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, notification],
          };
        });
      },

      requestDocuments: async (projectId, userId, userName, userRole, office, documentsNeeded, comments) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const approvalAction: ApprovalAction = {
            id: `action_${Date.now()}`,
            actionBy: { userId, name: userName, role: userRole, office },
            action: 'request_documents',
            comments,
            documentsRequested: documentsNeeded,
            timestamp: new Date(),
          };

          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;

          const updatedProject: ProjectSubmission = {
            ...project,
            status: 'under_review',
            approvalHistory: [...project.approvalHistory, approvalAction],
          };

          const notification: Notification = {
            id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            userId: submitterIdentifier,
            type: 'document_request',
            title: 'Additional Documents Requested 📄',
            message: `${userName} (${office}) requested additional documents for "${project.title}": ${documentsNeeded.join(', ')}`,
            projectId,
            read: false,
            timestamp: new Date(),
            actionRequired: true,
          };

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, notification],
          };
        });
      },

      uploadDocument: async (projectId, documentData) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const newDocument: ProjectDocument = {
            ...documentData,
            id: `doc_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            uploadedAt: new Date(),
          };

          const updatedProject: ProjectSubmission = {
            ...project,
            documents: [...project.documents, newDocument],
          };

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
          };
        });
      },

      forwardProject: async (projectId, userId, userName, userRole, office, forwardTo, comments) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const approvalAction: ApprovalAction = {
            id: `action_${Date.now()}`,
            actionBy: { userId, name: userName, role: userRole, office },
            action: 'forward',
            forwardedTo: forwardTo,
            comments,
            timestamp: new Date(),
          };

          const updatedProject: ProjectSubmission = {
            ...project,
            status: 'forwarded',
            approvalHistory: [...project.approvalHistory, approvalAction],
            currentHolder: forwardTo,
          };

          // Create notification for submitter - use their role if they're government
          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;

          // Create notifications
          const notifications: Notification[] = [
            // Notification for the person receiving the forward
            {
              id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
              userId: forwardTo,
              type: 'forward',
              title: 'Project Forwarded to You ➡️',
              message: `${userName} (${office}) forwarded "${project.title}" for your review. Comments: ${comments}`,
              projectId,
              read: false,
              timestamp: new Date(),
              actionRequired: true,
            },
            // Notification for original submitter
            {
              id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
              userId: submitterIdentifier,
              type: 'status_update',
              title: 'Project Forwarded 📤',
              message: `${userName} forwarded "${project.title}" to another authority for review`,
              projectId,
              read: false,
              timestamp: new Date(),
              actionRequired: false,
            },
          ];

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, ...notifications],
          };
        });
      },

      addComment: async (projectId, userId, userName, userRole, text, isInternal) => {
        set((state) => {
          const project = state.projects.find((p) => p.id === projectId);
          if (!project) return state;

          const comment: Comment = {
            id: `comment_${Date.now()}`,
            userId,
            userName,
            userRole,
            text,
            timestamp: new Date(),
            isInternal,
          };

          const updatedProject: ProjectSubmission = {
            ...project,
            comments: [...project.comments, comment],
          };

          // Create notification for submitter (if not internal and not from submitter)
          const notifications: Notification[] = [];
          
          // Use role for government users, userId for citizens
          const submitterIdentifier = project.submittedBy.role !== 'citizen' 
            ? project.submittedBy.role 
            : project.submittedBy.userId;
          
          // Check if commenter is different from submitter (compare both role and userId)
          const isDifferentUser = userId !== project.submittedBy.userId && 
                                   userRole !== project.submittedBy.role;
          
          if (!isInternal && isDifferentUser) {
            notifications.push({
              id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
              userId: submitterIdentifier,
              type: 'comment',
              title: 'New Comment on Your Project 💬',
              message: `${userName} commented on "${project.title}": ${text.substring(0, 100)}${text.length > 100 ? '...' : ''}`,
              projectId,
              read: false,
              timestamp: new Date(),
            });
          }

          return {
            projects: state.projects.map((p) => (p.id === projectId ? updatedProject : p)),
            notifications: [...state.notifications, ...notifications],
          };
        });
      },

      getIncomingRequests: (userId, userRole) => {
        const { projects } = get();
        return projects.filter(
          (project) => {
            // Check if this user's role is in the submittedTo list OR if their userId is there
            const roleMatch = project.submittedTo.some(id => id === userRole || id.startsWith(userRole));
            const userMatch = project.submittedTo.includes(userId);
            const holderRoleMatch = project.currentHolder === userRole || project.currentHolder.startsWith(userRole);
            const holderUserMatch = project.currentHolder === userId;
            
            return (roleMatch || userMatch) && 
                   (holderRoleMatch || holderUserMatch) &&
                   ['pending_review', 'under_review', 'forwarded'].includes(project.status);
          }
        );
      },

      getMySubmissions: (userId) => {
        const { projects } = get();
        return projects.filter((project) => project.submittedBy.userId === userId);
      },

      getProjectById: (projectId) => {
        const { projects } = get();
        return projects.find((p) => p.id === projectId);
      },

      getNotifications: (userId, userRole) => {
        const { notifications } = get();
        return notifications
          .filter((n) => n.userId === userId || n.userId === userRole)
          .sort((a, b) => {
            const timeA = a.timestamp instanceof Date ? a.timestamp.getTime() : new Date(a.timestamp).getTime();
            const timeB = b.timestamp instanceof Date ? b.timestamp.getTime() : new Date(b.timestamp).getTime();
            return timeB - timeA;
          });
      },

      markNotificationRead: (notificationId) => {
        set((state) => ({
          notifications: state.notifications.map((n) =>
            n.id === notificationId ? { ...n, read: true } : n
          ),
        }));
      },

      markAllNotificationsRead: (userId, userRole) => {
        set((state) => ({
          notifications: state.notifications.map((n) =>
            (n.userId === userId || n.userId === userRole) ? { ...n, read: true } : n
          ),
        }));
      },

      getApprovedProjects: () => {
        const { projects } = get();
        return projects.filter((project) => project.status === 'approved');
      },
    }),
    {
      name: 'approval-workflow-storage',
      partialize: (state) => ({
        projects: state.projects,
        notifications: state.notifications,
      }),
      // Custom storage to handle Date objects
      storage: {
        getItem: (name) => {
          const str = localStorage.getItem(name);
          if (!str) return null;
          
          try {
            const { state } = JSON.parse(str);
            
            // Convert date strings back to Date objects
            if (state.projects) {
              state.projects = state.projects.map((project: any) => ({
                ...project,
                submittedDate: new Date(project.submittedDate),
                approvedDate: project.approvedDate ? new Date(project.approvedDate) : undefined,
                startDate: project.startDate ? new Date(project.startDate) : undefined,
                expectedEndDate: project.expectedEndDate ? new Date(project.expectedEndDate) : undefined,
                approvalHistory: project.approvalHistory?.map((action: any) => ({
                  ...action,
                  timestamp: new Date(action.timestamp),
                })) || [],
                comments: project.comments?.map((comment: any) => ({
                  ...comment,
                  timestamp: new Date(comment.timestamp),
                })) || [],
                documents: project.documents?.map((doc: any) => ({
                  ...doc,
                  uploadedAt: new Date(doc.uploadedAt),
                })) || [],
              }));
            }
            
            if (state.notifications) {
              state.notifications = state.notifications.map((notif: any) => ({
                ...notif,
                timestamp: new Date(notif.timestamp),
              }));
            }
            
            return JSON.stringify({ state });
          } catch (error) {
            console.error('Error parsing stored data:', error);
            return null;
          }
        },
        setItem: (name, value) => {
          localStorage.setItem(name, value);
        },
        removeItem: (name) => {
          localStorage.removeItem(name);
        },
      },
    }
  )
);
