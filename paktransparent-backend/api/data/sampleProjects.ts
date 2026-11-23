/**
 * Sample Projects Data Generator
 * 
 * This file generates sample/demo projects dynamically.
 * Can be easily disabled via configuration or environment variables.
 */

import { Project } from '@/types';
import { SAMPLE_DATA_CONFIG } from '@/config/app.config';

/**
 * Generate sample projects for demonstration
 * These are only shown if SAMPLE_DATA_CONFIG.sampleProjects.enabled is true
 */
export const generateSampleProjects = (): Project[] => {
  if (!SAMPLE_DATA_CONFIG.sampleProjects.enabled) {
    return [];
  }

  const sampleProjects: Project[] = [
    {
      id: 'sample_1',
      projectId: 'NHA-2021-BR-009',
      name: 'National Highway Connectivity Bridge',
      description: 'The National Highway Connectivity Bridge is a critical infrastructure project aimed at reducing travel time between major economic hubs by 40%.',
      category: 'infrastructure',
      status: 'in_progress',
      province: 'punjab',
      district: 'Lahore',
      location: {
        lat: 31.5204,
        lng: 74.3587,
        address: 'Ravi River, Lahore',
      },
      budgetAllocated: 45200000000,
      budgetReleased: 33900000000,
      budgetSpent: 33900000000,
      budgetRemaining: 11300000000,
      currency: 'PKR',
      startDate: new Date('2021-01-15'),
      expectedEndDate: new Date('2024-12-31'),
      completionPercentage: 75,
      department: 'Ministry of Communications',
      contractor: {
        id: 'c1',
        name: 'Apex Construction Consortium',
        contactPerson: 'Engr. Hassan Ali',
        phone: '+92-300-1234567',
      },
      heroImage: 'https://images.unsplash.com/photo-1587023616175-d08b94b2f0e2?w=1200',
      images: [],
      videos: [],
      documents: [],
      milestones: [
        {
          id: 'm1',
          title: 'Foundation Laid',
          status: 'completed',
          targetDate: new Date('2021-08-01'),
          completedDate: new Date('2021-08-15'),
          order: 1,
        },
        {
          id: 'm2',
          title: 'Pillar Construction',
          status: 'completed',
          targetDate: new Date('2022-05-01'),
          completedDate: new Date('2022-05-20'),
          order: 2,
        },
        {
          id: 'm3',
          title: 'Deck Installation',
          status: 'in_progress',
          targetDate: new Date('2024-03-01'),
          order: 3,
        },
        {
          id: 'm4',
          title: 'Final Surfacing & Testing',
          status: 'pending',
          targetDate: new Date('2024-09-01'),
          order: 4,
        },
      ],
      followers: 12450,
      viewCount: 45320,
      createdAt: new Date('2021-01-01'),
      updatedAt: new Date(),
      createdBy: 'sample_gov_user_1',
    },
    {
      id: 'sample_2',
      projectId: 'LDA-2022-TR-045',
      name: 'Green Line Metro Extension',
      description: 'Extension of the existing metro line to connect suburban areas with the city center.',
      category: 'transport',
      status: 'approved',
      province: 'punjab',
      district: 'Lahore',
      location: {
        lat: 31.5497,
        lng: 74.3436,
        address: 'Gulberg, Lahore',
      },
      budgetAllocated: 22000000000,
      budgetReleased: 5000000000,
      budgetSpent: 0,
      budgetRemaining: 22000000000,
      currency: 'PKR',
      startDate: new Date('2024-03-01'),
      expectedEndDate: new Date('2026-12-31'),
      completionPercentage: 0,
      department: 'Lahore Development Authority',
      heroImage: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1200',
      images: [],
      videos: [],
      documents: [],
      milestones: [],
      followers: 8900,
      viewCount: 23450,
      createdAt: new Date('2022-06-15'),
      updatedAt: new Date(),
      createdBy: 'sample_gov_user_2',
    },
    {
      id: 'sample_3',
      projectId: 'MOH-2023-HC-087',
      name: 'District Hospital Modernization',
      description: 'Comprehensive upgrade of district hospital facilities including new equipment and infrastructure.',
      category: 'healthcare',
      status: 'in_progress',
      province: 'sindh',
      district: 'Karachi',
      location: {
        lat: 24.8607,
        lng: 67.0011,
        address: 'Saddar, Karachi',
      },
      budgetAllocated: 5000000000,
      budgetReleased: 3000000000,
      budgetSpent: 2500000000,
      budgetRemaining: 2500000000,
      currency: 'PKR',
      startDate: new Date('2023-01-01'),
      expectedEndDate: new Date('2024-06-30'),
      completionPercentage: 50,
      department: 'Ministry of Health',
      heroImage: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=1200',
      images: [],
      videos: [],
      documents: [],
      milestones: [],
      followers: 15600,
      viewCount: 34200,
      createdAt: new Date('2022-12-01'),
      updatedAt: new Date(),
      createdBy: 'sample_gov_user_3',
    },
  ];

  // Return only the configured number of sample projects
  return sampleProjects.slice(0, SAMPLE_DATA_CONFIG.sampleProjects.count);
};

/**
 * Check if sample data should be displayed
 */
export const shouldShowSampleData = (): boolean => {
  return SAMPLE_DATA_CONFIG.enabled && SAMPLE_DATA_CONFIG.sampleProjects.enabled;
};

/**
 * Get a single sample project by ID
 */
export const getSampleProjectById = (id: string): Project | undefined => {
  const samples = generateSampleProjects();
  return samples.find(p => p.id === id);
};
