/**
 * Government Project Store
 * 
 * Enhanced project management for government users
 * - Create and edit projects
 * - Upload project images and documents dynamically
 * - Manage project media
 * - Real-time updates
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Project } from '@/types';
import { uploadFile, uploadFiles, UploadedFile } from '@/services/fileUploadService';
import { createAuditLog } from '@/services/securityService';

interface GovernmentProjectState {
  projects: Project[];
  isLoading: boolean;
  error: string | null;
  
  // Actions
  createProject: (projectData: Omit<Project, 'id' | 'createdAt' | 'updatedAt' | 'viewCount' | 'followers'>) => Promise<Project>;
  updateProject: (projectId: string, updates: Partial<Project>) => Promise<void>;
  deleteProject: (projectId: string) => Promise<void>;
  uploadProjectHeroImage: (projectId: string, file: File, userId: string) => Promise<void>;
  uploadProjectImages: (projectId: string, files: File[], userId: string) => Promise<void>;
  uploadProjectDocuments: (projectId: string, files: File[], userId: string) => Promise<void>;
  deleteProjectMedia: (projectId: string, mediaType: 'images' | 'documents', mediaId: string) => Promise<void>;
  fetchGovernmentProjects: () => Promise<void>;
  getProjectById: (projectId: string) => Project | undefined;
}

const STORAGE_KEY = 'government_projects';

export const useGovernmentProjectStore = create<GovernmentProjectState>()(
  persist(
    (set, get) => ({
      projects: [],
      isLoading: false,
      error: null,

      createProject: async (projectData) => {
        set({ isLoading: true, error: null });
        
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 1000));
          
          const newProject: Project = {
            ...projectData,
            id: `proj_${Date.now()}`,
            viewCount: 0,
            followers: 0,
            createdAt: new Date(),
            updatedAt: new Date(),
            images: projectData.images || [],
            videos: projectData.videos || [],
            documents: projectData.documents || [],
          };

          set(state => ({
            projects: [newProject, ...state.projects],
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            projectData.createdBy,
            'CREATE_PROJECT',
            `project:${newProject.id}`,
            true,
            { projectId: newProject.projectId, name: newProject.name }
          );

          return newProject;
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to create project';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      updateProject: async (projectId, updates) => {
        set({ isLoading: true, error: null });
        
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 800));
          
          set(state => ({
            projects: state.projects.map(project =>
              project.id === projectId
                ? { ...project, ...updates, updatedAt: new Date() }
                : project
            ),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            updates.createdBy || 'system',
            'UPDATE_PROJECT',
            `project:${projectId}`,
            true,
            { updates }
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to update project';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      deleteProject: async (projectId) => {
        set({ isLoading: true, error: null });
        
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 800));
          
          set(state => ({
            projects: state.projects.filter(project => project.id !== projectId),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            'system',
            'DELETE_PROJECT',
            `project:${projectId}`,
            true
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to delete project';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      uploadProjectHeroImage: async (projectId, file, userId) => {
        set({ isLoading: true, error: null });
        
        try {
          // Upload file and convert to base64
          const uploadedFile = await uploadFile(file, userId, {
            maxSizeMB: 5,
            allowedTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
          });

          // Update project with new hero image
          set(state => ({
            projects: state.projects.map(project =>
              project.id === projectId
                ? { ...project, heroImage: uploadedFile.url, updatedAt: new Date() }
                : project
            ),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            userId,
            'UPLOAD_PROJECT_HERO_IMAGE',
            `project:${projectId}`,
            true,
            { fileName: file.name }
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to upload hero image';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      uploadProjectImages: async (projectId, files, userId) => {
        set({ isLoading: true, error: null });
        
        try {
          // Upload all files
          const uploadedFiles = await uploadFiles(files, userId, {
            maxSizeMB: 5,
            allowedTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
          });

          // Update project with new images
          set(state => ({
            projects: state.projects.map(project => {
              if (project.id === projectId) {
                const existingImages = project.images || [];
                return {
                  ...project,
                  images: [...existingImages, ...uploadedFiles],
                  updatedAt: new Date(),
                };
              }
              return project;
            }),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            userId,
            'UPLOAD_PROJECT_IMAGES',
            `project:${projectId}`,
            true,
            { fileCount: files.length }
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to upload images';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      uploadProjectDocuments: async (projectId, files, userId) => {
        set({ isLoading: true, error: null });
        
        try {
          // Upload all files
          const uploadedFiles = await uploadFiles(files, userId, {
            maxSizeMB: 10,
            allowedTypes: [
              'application/pdf',
              'application/msword',
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              'application/vnd.ms-excel',
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ],
          });

          // Update project with new documents
          set(state => ({
            projects: state.projects.map(project => {
              if (project.id === projectId) {
                const existingDocs = project.documents || [];
                return {
                  ...project,
                  documents: [...existingDocs, ...uploadedFiles],
                  updatedAt: new Date(),
                };
              }
              return project;
            }),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            userId,
            'UPLOAD_PROJECT_DOCUMENTS',
            `project:${projectId}`,
            true,
            { fileCount: files.length }
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to upload documents';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      deleteProjectMedia: async (projectId, mediaType, mediaId) => {
        set({ isLoading: true, error: null });
        
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 500));
          
          set(state => ({
            projects: state.projects.map(project => {
              if (project.id === projectId) {
                if (mediaType === 'images') {
                  return {
                    ...project,
                    images: (project.images || []).filter(img => img.id !== mediaId),
                    updatedAt: new Date(),
                  };
                } else if (mediaType === 'documents') {
                  return {
                    ...project,
                    documents: (project.documents || []).filter(doc => doc.id !== mediaId),
                    updatedAt: new Date(),
                  };
                }
              }
              return project;
            }),
            isLoading: false,
          }));

          // Create audit log
          createAuditLog(
            'system',
            'DELETE_PROJECT_MEDIA',
            `project:${projectId}`,
            true,
            { mediaType, mediaId }
          );
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to delete media';
          set({ error: errorMessage, isLoading: false });
          throw new Error(errorMessage);
        }
      },

      fetchGovernmentProjects: async () => {
        set({ isLoading: true, error: null });
        
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 500));
          
          // Projects are already loaded from persistence
          set({ isLoading: false });
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Failed to fetch projects';
          set({ error: errorMessage, isLoading: false });
        }
      },

      getProjectById: (projectId) => {
        const { projects } = get();
        return projects.find(p => p.id === projectId);
      },
    }),
    {
      name: STORAGE_KEY,
      partialize: (state) => ({ projects: state.projects }),
    }
  )
);

export default useGovernmentProjectStore;
