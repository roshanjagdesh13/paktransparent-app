import { create } from 'zustand';
import {
  ApprovalWorkflow,
  TaskAssignment,
  PriorityIssue,
  GovernmentRole,
  GOVERNMENT_HIERARCHY,
  canUserApproveProject,
  getApprovalChain,
} from '@/types/government';

interface ApprovalState {
  workflows: ApprovalWorkflow[];
  tasks: TaskAssignment[];
  priorityIssues: PriorityIssue[];
  isLoading: boolean;
  error: string | null;

  // Actions
  fetchWorkflows: (userRole: GovernmentRole) => Promise<void>;
  createWorkflow: (workflow: Omit<ApprovalWorkflow, 'id' | 'createdAt' | 'updatedAt'>) => Promise<string>;
  approveWorkflow: (workflowId: string, userId: string, userRole: GovernmentRole, comments?: string) => Promise<void>;
  rejectWorkflow: (workflowId: string, userId: string, userRole: GovernmentRole, comments: string) => Promise<void>;
  escalateWorkflow: (workflowId: string, userId: string, userRole: GovernmentRole) => Promise<void>;
  
  fetchTasks: (userId: string) => Promise<void>;
  createTask: (task: Omit<TaskAssignment, 'id' | 'createdAt'>) => Promise<void>;
  updateTaskStatus: (taskId: string, status: TaskAssignment['status']) => Promise<void>;
  
  fetchPriorityIssues: (userRole: GovernmentRole) => Promise<void>;
  createPriorityIssue: (issue: Omit<PriorityIssue, 'id' | 'createdAt'>) => Promise<void>;
}

export const useApprovalStore = create<ApprovalState>((set, get) => ({
  workflows: [],
  tasks: [],
  priorityIssues: [],
  isLoading: false,
  error: null,

  fetchWorkflows: async (userRole: GovernmentRole) => {
    set({ isLoading: true, error: null });
    
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Load from localStorage
      const saved = localStorage.getItem('approval_workflows');
      const allWorkflows: ApprovalWorkflow[] = saved ? JSON.parse(saved) : [];
      
      // Filter workflows relevant to this role
      const hierarchy = GOVERNMENT_HIERARCHY[userRole];
      
      if (!hierarchy) {
        set({ workflows: [], isLoading: false });
        return;
      }
      
      const relevantWorkflows = allWorkflows.filter(workflow => {
        // Show if user needs to approve
        if (workflow.status === 'pending' && 
            workflow.currentApprovalLevel === hierarchy.level) {
          return true;
        }
        // Show if user created it
        if (workflow.submittedBy.role === userRole) {
          return true;
        }
        return false;
      });

      set({ workflows: relevantWorkflows, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to fetch workflows', isLoading: false });
    }
  },

  createWorkflow: async (workflowData) => {
    set({ isLoading: true, error: null });
    
    try {
      const newWorkflow: ApprovalWorkflow = {
        ...workflowData,
        id: `workflow_${Date.now()}`,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Save to localStorage
      const saved = localStorage.getItem('approval_workflows');
      const workflows = saved ? JSON.parse(saved) : [];
      workflows.push(newWorkflow);
      localStorage.setItem('approval_workflows', JSON.stringify(workflows));

      set(state => ({
        workflows: [...state.workflows, newWorkflow],
        isLoading: false,
      }));

      return newWorkflow.id;
    } catch (error) {
      set({ error: 'Failed to create workflow', isLoading: false });
      throw error;
    }
  },

  approveWorkflow: async (workflowId, userId, userRole, comments) => {
    try {
      const { workflows } = get();
      const workflow = workflows.find(w => w.id === workflowId);
      
      if (!workflow) {
        throw new Error('Workflow not found');
      }

      // Check if user can approve
      const canApprove = canUserApproveProject(userRole, workflow.projectBudget);
      if (!canApprove.canApprove) {
        throw new Error(canApprove.reason);
      }

      // Update approval chain
      const updatedChain = workflow.approvalChain.map(step => {
        if (step.approverRole === userRole && step.status === 'pending') {
          return {
            ...step,
            status: 'approved' as const,
            approverId: userId,
            comments,
            timestamp: new Date(),
          };
        }
        return step;
      });

      // Check if all required approvals are done
      const allApproved = updatedChain
        .filter(step => step.level <= workflow.requiredApprovalLevel)
        .every(step => step.status === 'approved');

      const updatedWorkflow: ApprovalWorkflow = {
        ...workflow,
        approvalChain: updatedChain,
        status: allApproved ? 'approved' : 'pending',
        currentApprovalLevel: allApproved 
          ? workflow.requiredApprovalLevel 
          : (workflow.currentApprovalLevel - 1) as any,
        updatedAt: new Date(),
      };

      // Save to localStorage
      const saved = localStorage.getItem('approval_workflows');
      const allWorkflows = saved ? JSON.parse(saved) : [];
      const updatedWorkflows = allWorkflows.map((w: ApprovalWorkflow) => 
        w.id === workflowId ? updatedWorkflow : w
      );
      localStorage.setItem('approval_workflows', JSON.stringify(updatedWorkflows));

      set(state => ({
        workflows: state.workflows.map(w => 
          w.id === workflowId ? updatedWorkflow : w
        ),
      }));
    } catch (error) {
      console.error('Approval error:', error);
      throw error;
    }
  },

  rejectWorkflow: async (workflowId, userId, userRole, comments) => {
    try {
      const { workflows } = get();
      const workflow = workflows.find(w => w.id === workflowId);
      
      if (!workflow) {
        throw new Error('Workflow not found');
      }

      // Update approval chain
      const updatedChain = workflow.approvalChain.map(step => {
        if (step.approverRole === userRole && step.status === 'pending') {
          return {
            ...step,
            status: 'rejected' as const,
            approverId: userId,
            comments,
            timestamp: new Date(),
          };
        }
        return step;
      });

      const updatedWorkflow: ApprovalWorkflow = {
        ...workflow,
        approvalChain: updatedChain,
        status: 'rejected',
        updatedAt: new Date(),
      };

      // Save to localStorage
      const saved = localStorage.getItem('approval_workflows');
      const allWorkflows = saved ? JSON.parse(saved) : [];
      const updatedWorkflows = allWorkflows.map((w: ApprovalWorkflow) => 
        w.id === workflowId ? updatedWorkflow : w
      );
      localStorage.setItem('approval_workflows', JSON.stringify(updatedWorkflows));

      set(state => ({
        workflows: state.workflows.map(w => 
          w.id === workflowId ? updatedWorkflow : w
        ),
      }));
    } catch (error) {
      console.error('Rejection error:', error);
      throw error;
    }
  },

  escalateWorkflow: async (workflowId, userId, userRole) => {
    try {
      const { workflows } = get();
      const workflow = workflows.find(w => w.id === workflowId);
      
      if (!workflow) {
        throw new Error('Workflow not found');
      }

      const hierarchy = GOVERNMENT_HIERARCHY[userRole];
      if (!hierarchy || !hierarchy.reportsTo) {
        throw new Error('Cannot escalate - no higher authority');
      }

      const updatedChain = workflow.approvalChain.map(step => {
        if (step.approverRole === userRole && step.status === 'pending') {
          return {
            ...step,
            status: 'escalated' as const,
            approverId: userId,
            timestamp: new Date(),
          };
        }
        return step;
      });

      const updatedWorkflow: ApprovalWorkflow = {
        ...workflow,
        approvalChain: updatedChain,
        status: 'escalated',
        updatedAt: new Date(),
      };

      // Save to localStorage
      const saved = localStorage.getItem('approval_workflows');
      const allWorkflows = saved ? JSON.parse(saved) : [];
      const updatedWorkflows = allWorkflows.map((w: ApprovalWorkflow) => 
        w.id === workflowId ? updatedWorkflow : w
      );
      localStorage.setItem('approval_workflows', JSON.stringify(updatedWorkflows));

      set(state => ({
        workflows: state.workflows.map(w => 
          w.id === workflowId ? updatedWorkflow : w
        ),
      }));
    } catch (error) {
      console.error('Escalation error:', error);
      throw error;
    }
  },

  fetchTasks: async (userId) => {
    set({ isLoading: true, error: null });
    
    try {
      await new Promise(resolve => setTimeout(resolve, 300));
      
      const saved = localStorage.getItem('task_assignments');
      const allTasks: TaskAssignment[] = saved ? JSON.parse(saved) : [];
      
      // Filter tasks assigned to this user
      const userTasks = allTasks.filter(task => task.assignedTo.userId === userId);

      set({ tasks: userTasks, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to fetch tasks', isLoading: false });
    }
  },

  createTask: async (taskData) => {
    try {
      const newTask: TaskAssignment = {
        ...taskData,
        id: `task_${Date.now()}`,
        createdAt: new Date(),
      };

      const saved = localStorage.getItem('task_assignments');
      const tasks = saved ? JSON.parse(saved) : [];
      tasks.push(newTask);
      localStorage.setItem('task_assignments', JSON.stringify(tasks));

      set(state => ({
        tasks: [...state.tasks, newTask],
      }));
    } catch (error) {
      console.error('Task creation error:', error);
      throw error;
    }
  },

  updateTaskStatus: async (taskId, status) => {
    try {
      const saved = localStorage.getItem('task_assignments');
      const allTasks = saved ? JSON.parse(saved) : [];
      const updatedTasks = allTasks.map((t: TaskAssignment) => 
        t.id === taskId ? { ...t, status } : t
      );
      localStorage.setItem('task_assignments', JSON.stringify(updatedTasks));

      set(state => ({
        tasks: state.tasks.map(t => 
          t.id === taskId ? { ...t, status } : t
        ),
      }));
    } catch (error) {
      console.error('Task update error:', error);
      throw error;
    }
  },

  fetchPriorityIssues: async (userRole) => {
    set({ isLoading: true, error: null });
    
    try {
      await new Promise(resolve => setTimeout(resolve, 300));
      
      const saved = localStorage.getItem('priority_issues');
      const allIssues: PriorityIssue[] = saved ? JSON.parse(saved) : [];
      
      const hierarchy = GOVERNMENT_HIERARCHY[userRole];
      
      if (!hierarchy) {
        set({ priorityIssues: [], isLoading: false });
        return;
      }
      
      // Filter issues relevant to this role's level
      const relevantIssues = allIssues.filter(issue => {
        return issue.requiresAttentionFrom >= hierarchy.level;
      });

      set({ priorityIssues: relevantIssues, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to fetch priority issues', isLoading: false });
    }
  },

  createPriorityIssue: async (issueData) => {
    try {
      const newIssue: PriorityIssue = {
        ...issueData,
        id: `issue_${Date.now()}`,
        createdAt: new Date(),
      };

      const saved = localStorage.getItem('priority_issues');
      const issues = saved ? JSON.parse(saved) : [];
      issues.push(newIssue);
      localStorage.setItem('priority_issues', JSON.stringify(issues));

      set(state => ({
        priorityIssues: [...state.priorityIssues, newIssue],
      }));
    } catch (error) {
      console.error('Priority issue creation error:', error);
      throw error;
    }
  },
}));
