import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { UploadedFile } from '@/services/fileUploadService';

export interface Report {
  id: string;
  title: string;
  category: string;
  description: string;
  status: 'submitted' | 'under_review' | 'resolved' | 'rejected';
  isAnonymous: boolean;
  files: UploadedFile[]; // Enhanced file storage
  images: UploadedFile[]; // Separate array for images
  documents: UploadedFile[]; // Separate array for documents
  projectId?: string;
  projectName?: string;
  submittedBy: {
    id: string;
    name: string;
    email: string;
  };
  submittedAt: Date;
  updatedAt: Date;
  reviewedBy?: string;
  reviewNotes?: string;
  priority?: 'low' | 'medium' | 'high' | 'critical';
}

interface ReportStore {
  reports: Report[];
  isLoading: boolean;
  error: string | null;
  
  // Actions
  submitReport: (reportData: Omit<Report, 'id' | 'submittedAt' | 'updatedAt' | 'status' | 'images' | 'documents'>) => Promise<void>;
  fetchUserReports: () => Promise<void>;
  fetchAllReports: () => Promise<void>;
  updateReportStatus: (reportId: string, status: Report['status'], notes?: string) => Promise<void>;
  deleteReport: (reportId: string) => Promise<void>;
  getReportById: (reportId: string) => Report | undefined;
}

export const useReportStore = create<ReportStore>()(
  persist(
    (set, get) => ({
      reports: [],
      isLoading: false,
      error: null,

  submitReport: async (reportData) => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Separate files into images and documents
      const images = reportData.files?.filter(f => f.category === 'image') || [];
      const documents = reportData.files?.filter(f => f.category === 'document') || [];
      
      const newReport: Report = {
        ...reportData,
        files: reportData.files || [],
        images,
        documents,
        id: `RPT-${Date.now()}`,
        status: 'submitted',
        submittedAt: new Date(),
        updatedAt: new Date(),
      };

      set(state => ({
        reports: [newReport, ...state.reports],
        isLoading: false,
      }));

      console.log('Report submitted:', newReport);
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to submit report',
        isLoading: false 
      });
      throw error;
    }
  },

  fetchUserReports: async () => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // In a real app, this would filter on the server side
      // For now, we keep all reports in the store and filter in the UI
      set({ isLoading: false });
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to fetch reports',
        isLoading: false 
      });
    }
  },

  fetchAllReports: async () => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // In a real app, this would fetch from API
      // For now, we keep all reports in the store
      set({ isLoading: false });
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to fetch reports',
        isLoading: false 
      });
    }
  },

  updateReportStatus: async (reportId, status, notes) => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 800));
      
      set(state => ({
        reports: state.reports.map(report =>
          report.id === reportId
            ? {
                ...report,
                status,
                reviewNotes: notes,
                updatedAt: new Date(),
              }
            : report
        ),
        isLoading: false,
      }));
      
      console.log(`Report ${reportId} status updated to ${status}`);
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to update report',
        isLoading: false 
      });
      throw error;
    }
  },

  deleteReport: async (reportId) => {
    set({ isLoading: true, error: null });
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 800));
      
      set(state => ({
        reports: state.reports.filter(report => report.id !== reportId),
        isLoading: false,
      }));
      
      console.log(`Report ${reportId} deleted`);
    } catch (error) {
      set({ 
        error: error instanceof Error ? error.message : 'Failed to delete report',
        isLoading: false 
      });
      throw error;
    }
  },

  getReportById: (reportId) => {
    const { reports } = get();
    return reports.find(r => r.id === reportId);
  },
    }),
    {
      name: 'pak-transparent-reports',
      partialize: (state) => ({ reports: state.reports }),
      // Custom storage handler to properly serialize/deserialize dates
      storage: {
        getItem: (name) => {
          const str = localStorage.getItem(name);
          if (!str) return null;
          const { state } = JSON.parse(str);
          // Convert date strings back to Date objects
          if (state.reports) {
            state.reports = state.reports.map((report: any) => ({
              ...report,
              submittedAt: new Date(report.submittedAt),
              updatedAt: new Date(report.updatedAt),
              files: report.files?.map((file: any) => ({
                ...file,
                uploadedAt: new Date(file.uploadedAt),
              })),
              images: report.images?.map((file: any) => ({
                ...file,
                uploadedAt: new Date(file.uploadedAt),
              })),
              documents: report.documents?.map((file: any) => ({
                ...file,
                uploadedAt: new Date(file.uploadedAt),
              })),
            }));
          }
          return { state };
        },
        setItem: (name, value) => {
          localStorage.setItem(name, JSON.stringify(value));
        },
        removeItem: (name) => {
          localStorage.removeItem(name);
        },
      },
    }
  )
);
