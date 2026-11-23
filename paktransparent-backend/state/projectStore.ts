import { create } from 'zustand';
import { Project, ProjectFilters } from '@/types';

interface ProjectState {
  projects: Project[];
  selectedProject: Project | null;
  filters: ProjectFilters;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  fetchProjects: (filters?: ProjectFilters) => Promise<void>;
  fetchProjectById: (id: string) => Promise<void>;
  setFilters: (filters: ProjectFilters) => void;
  clearFilters: () => void;
  setSelectedProject: (project: Project | null) => void;
  bookmarkProject: (projectId: string) => void;
  followProject: (projectId: string) => void;
}

export const useProjectStore = create<ProjectState>((set, get) => ({
  projects: [],
  selectedProject: null,
  filters: {},
  isLoading: false,
  error: null,

  fetchProjects: async (filters?: ProjectFilters) => {
    set({ isLoading: true, error: null });
    
    try {
      // Mock API call - Replace with actual API
      await new Promise(resolve => setTimeout(resolve, 800));
      
      // Load government-created projects from localStorage
      const savedProjects = localStorage.getItem('government_projects');
      let governmentProjects: Project[] = [];
      
      if (savedProjects) {
        try {
          const parsed = JSON.parse(savedProjects);
          // Handle both direct array and nested state structure
          governmentProjects = parsed.state?.projects || parsed.projects || parsed;
        } catch (e) {
          console.error('Failed to parse government projects:', e);
        }
      }
      
      // Import sample projects dynamically
      const { generateSampleProjects } = await import('@/data/sampleProjects');
      const sampleProjects = generateSampleProjects();

      // Combine sample projects with government-created projects
      // Government projects come first (more recent)
      let allProjects = [...governmentProjects, ...sampleProjects];

      // Apply filters
      let filteredProjects = allProjects;
      
      if (filters?.province) {
        filteredProjects = filteredProjects.filter(p => p.province === filters.province);
      }
      
      if (filters?.category) {
        filteredProjects = filteredProjects.filter(p => p.category === filters.category);
      }
      
      if (filters?.status) {
        filteredProjects = filteredProjects.filter(p => p.status === filters.status);
      }

      set({ projects: filteredProjects, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to fetch projects', isLoading: false });
    }
  },

  fetchProjectById: async (id: string) => {
    set({ isLoading: true, error: null });
    
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const { projects } = get();
      const project = projects.find(p => p.id === id);
      
      if (project) {
        set({ selectedProject: project, isLoading: false });
      } else {
        set({ error: 'Project not found', isLoading: false });
      }
    } catch (error) {
      set({ error: 'Failed to fetch project', isLoading: false });
    }
  },

  setFilters: (filters: ProjectFilters) => {
    set({ filters });
  },

  clearFilters: () => {
    set({ filters: {} });
  },

  setSelectedProject: (project: Project | null) => {
    set({ selectedProject: project });
  },

  bookmarkProject: (projectId: string) => {
    // Mock bookmark functionality
    console.log('Bookmarked project:', projectId);
  },

  followProject: (projectId: string) => {
    // Mock follow functionality
    console.log('Following project:', projectId);
  },
}));
