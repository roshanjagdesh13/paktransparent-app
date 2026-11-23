// Application Constants

export const APP_NAME = import.meta.env.VITE_APP_NAME || 'PakTransparent';
export const APP_DESCRIPTION = import.meta.env.VITE_APP_DESCRIPTION || 'Pakistan Public Budget Tracker & Transparency Platform';

// API Configuration
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api';
export const API_TIMEOUT = parseInt(import.meta.env.VITE_API_TIMEOUT || '30000', 10);

// Currency
export const CURRENCY = import.meta.env.VITE_CURRENCY_CODE || 'PKR';
export const CURRENCY_SYMBOL = import.meta.env.VITE_CURRENCY_SYMBOL || 'Rs';

// Provinces
export const PROVINCES = {
  punjab: 'Punjab',
  sindh: 'Sindh',
  kpk: 'Khyber Pakhtunkhwa',
  balochistan: 'Balochistan',
  gilgit_baltistan: 'Gilgit-Baltistan',
  azad_kashmir: 'Azad Kashmir',
} as const;

// Project Categories
export const PROJECT_CATEGORIES = {
  infrastructure: 'Infrastructure',
  education: 'Education',
  healthcare: 'Healthcare',
  transport: 'Transport',
  energy: 'Energy',
  water: 'Water & Sanitation',
  agriculture: 'Agriculture',
  defense: 'Defense',
  social_welfare: 'Social Welfare',
  other: 'Other',
} as const;

// Project Status
export const PROJECT_STATUS = {
  pending: { label: 'Pending Approval', color: 'bg-surface-variant text-on-surface-variant' },
  approved: { label: 'Approved', color: 'bg-tertiary-fixed text-on-tertiary-fixed' },
  in_progress: { label: 'In Progress', color: 'bg-secondary-container text-on-secondary-container' },
  completed: { label: 'Completed', color: 'bg-primary-fixed text-on-primary-fixed' },
  suspended: { label: 'Suspended', color: 'bg-error-container text-on-error-container' },
  cancelled: { label: 'Cancelled', color: 'bg-outline text-surface' },
} as const;

// Report Status
export const REPORT_STATUS = {
  submitted: { label: 'Submitted', color: 'bg-tertiary-fixed text-on-tertiary-fixed' },
  under_review: { label: 'Under Review', color: 'bg-secondary-container text-on-secondary-container' },
  resolved: { label: 'Resolved', color: 'bg-primary-fixed text-on-primary-fixed' },
  rejected: { label: 'Rejected', color: 'bg-error-container text-on-error-container' },
} as const;

// Report Categories
export const REPORT_CATEGORIES = {
  delay: 'Project Delay',
  quality: 'Quality Issues',
  corruption: 'Corruption',
  mismanagement: 'Mismanagement',
  safety: 'Safety Concerns',
  environmental: 'Environmental Issues',
  other: 'Other',
} as const;

// Priority Levels
export const PRIORITY_LEVELS = {
  low: { label: 'Low', color: 'bg-surface-variant text-on-surface-variant' },
  medium: { label: 'Medium', color: 'bg-secondary-container text-on-secondary-container' },
  high: { label: 'High', color: 'bg-tertiary-container text-on-tertiary' },
  critical: { label: 'Critical', color: 'bg-error text-on-error' },
} as const;

// File Upload Limits
export const FILE_UPLOAD_LIMITS = {
  maxSize: parseInt(import.meta.env.VITE_MAX_FILE_SIZE || '52428800', 10), // 50MB default
  maxFiles: parseInt(import.meta.env.VITE_MAX_FILES || '10', 10),
  acceptedImages: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
  acceptedVideos: ['video/mp4', 'video/webm', 'video/quicktime'],
  acceptedDocuments: [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/zip',
  ],
} as const;

// Pagination
export const DEFAULT_PAGE_SIZE = parseInt(import.meta.env.VITE_DEFAULT_PAGE_SIZE || '20', 10);
export const PAGE_SIZE_OPTIONS = [10, 20, 50, 100];

// Date Formats
export const DATE_FORMAT = import.meta.env.VITE_DATE_FORMAT || 'dd MMM yyyy';
export const DATE_TIME_FORMAT = 'dd MMM yyyy, HH:mm';
export const MONTH_YEAR_FORMAT = 'MMM yyyy';

// Chart Colors
export const CHART_COLORS = {
  primary: '#004b00',
  secondary: '#286c1e',
  tertiary: '#003d87',
  success: '#81db6e',
  warning: '#f59e0b',
  error: '#ba1a1a',
  gray: '#707a6a',
};

// Navigation Items - Citizen
export const CITIZEN_NAV_ITEMS = [
  { path: '/dashboard', label: 'Home', icon: 'home' },
  { path: '/projects', label: 'Projects', icon: 'search' },
  { path: '/analytics', label: 'Analytics', icon: 'insights' },
  { path: '/reports', label: 'My Reports', icon: 'description' },
  { path: '/profile', label: 'Profile', icon: 'person' },
] as const;

// Extended Navigation Items - Citizen (for menu)
export const CITIZEN_EXTENDED_NAV = [
  { path: '/qr-scanner', label: 'QR Scanner', icon: 'qr_code_scanner' },
  { path: '/ai-insights', label: 'AI Insights', icon: 'psychology' },
  { path: '/budget-comparison', label: 'Budget Comparison', icon: 'compare_arrows' },
] as const;

// Navigation Items - Government
export const GOVERNMENT_NAV_ITEMS = [
  { path: '/gov/dashboard', label: 'Dashboard', icon: 'dashboard' },
  { path: '/gov/projects', label: 'Project Tracking', icon: 'analytics' },
  { path: '/gov/reports', label: 'Citizen Reports', icon: 'campaign' },
  { path: '/gov/audit', label: 'Audit Trail', icon: 'fact_check' },
  { path: '/gov/settings', label: 'Settings', icon: 'settings' },
] as const;

// Local Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: import.meta.env.VITE_AUTH_TOKEN_KEY || 'pak_transparent_token',
  USER_DATA: 'auth-storage',
  THEME: 'pak_transparent_theme',
  LANGUAGE: 'pak_transparent_lang',
  RECENT_SEARCHES: 'pak_transparent_recent_searches',
  BOOKMARKS: 'pak_transparent_bookmarks',
} as const;

// Fiscal Years
export const CURRENT_FISCAL_YEAR = '2024-2025';
export const FISCAL_YEARS = [
  '2024-2025',
  '2023-2024',
  '2022-2023',
  '2021-2022',
  '2020-2021',
] as const;

// Material Icons
export const MATERIAL_ICONS = {
  home: 'home',
  search: 'search',
  person: 'person',
  settings: 'settings',
  notifications: 'notifications',
  menu: 'menu',
  close: 'close',
  arrowBack: 'arrow_back',
  arrowForward: 'arrow_forward',
  dashboard: 'dashboard',
  analytics: 'analytics',
  accountBalance: 'account_balance',
  upload: 'upload_file',
  download: 'download',
  share: 'share',
  bookmark: 'bookmark',
  map: 'map',
  location: 'location_on',
  calendar: 'calendar_today',
  check: 'check',
  error: 'error',
  warning: 'warning',
  info: 'info',
  verified: 'verified',
} as const;

// Animation Durations
export const ANIMATION = {
  fast: 200,
  normal: 300,
  slow: 500,
} as const;

// Breakpoints (matching Tailwind)
export const BREAKPOINTS = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
} as const;
