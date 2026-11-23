/**
 * Application Configuration
 * 
 * This file contains all dynamic configuration settings for the application.
 * Update these values based on your environment and requirements.
 */

// ============================================
// APPLICATION SETTINGS
// ============================================

export const APP_CONFIG = {
  // Application Information
  name: import.meta.env.VITE_APP_NAME || 'PakTransparent',
  description: import.meta.env.VITE_APP_DESCRIPTION || 'Pakistan Public Budget Tracker & Transparency Platform',
  version: '1.0.0',
  
  // API Configuration
  api: {
    baseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api',
    timeout: parseInt(import.meta.env.VITE_API_TIMEOUT || '30000', 10),
    retryAttempts: parseInt(import.meta.env.VITE_API_RETRY_ATTEMPTS || '3', 10),
  },
  
  // Feature Flags - Enable/Disable Features
  features: {
    showMockProjects: import.meta.env.VITE_SHOW_MOCK_PROJECTS !== 'false', // Default true
    enableAIInsights: import.meta.env.VITE_ENABLE_AI_INSIGHTS !== 'false',
    enableQRScanner: import.meta.env.VITE_ENABLE_QR_SCANNER !== 'false',
    enableNotifications: import.meta.env.VITE_ENABLE_NOTIFICATIONS !== 'false',
    enableFileUpload: import.meta.env.VITE_ENABLE_FILE_UPLOAD !== 'false',
    enableAnalytics: import.meta.env.VITE_ENABLE_ANALYTICS !== 'false',
  },
  
  // Authentication
  auth: {
    tokenKey: 'pak_transparent_token',
    sessionTimeout: parseInt(import.meta.env.VITE_SESSION_TIMEOUT || '3600000', 10), // 1 hour default
    enableRememberMe: true,
  },
  
  // Storage Keys
  storage: {
    prefix: 'pak_transparent_',
    keys: {
      auth: 'auth-storage',
      workflow: 'approval-workflow-storage',
      projects: 'government_projects',
      theme: 'theme',
      language: 'lang',
      bookmarks: 'bookmarks',
      recentSearches: 'recent_searches',
    },
  },
  
  // Pagination
  pagination: {
    defaultPageSize: parseInt(import.meta.env.VITE_DEFAULT_PAGE_SIZE || '20', 10),
    pageSizeOptions: [10, 20, 50, 100],
  },
  
  // File Upload
  fileUpload: {
    maxSize: parseInt(import.meta.env.VITE_MAX_FILE_SIZE || '52428800', 10), // 50MB default
    maxFiles: parseInt(import.meta.env.VITE_MAX_FILES || '10', 10),
    allowedImageTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
    allowedVideoTypes: ['video/mp4', 'video/webm', 'video/quicktime'],
    allowedDocumentTypes: [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ],
  },
  
  // Maps & Location
  maps: {
    defaultCenter: {
      lat: parseFloat(import.meta.env.VITE_MAP_DEFAULT_LAT || '30.3753'),
      lng: parseFloat(import.meta.env.VITE_MAP_DEFAULT_LNG || '69.3451'),
    },
    defaultZoom: parseInt(import.meta.env.VITE_MAP_DEFAULT_ZOOM || '6', 10),
  },
  
  // Currency
  currency: {
    code: import.meta.env.VITE_CURRENCY_CODE || 'PKR',
    symbol: import.meta.env.VITE_CURRENCY_SYMBOL || 'Rs',
    locale: import.meta.env.VITE_CURRENCY_LOCALE || 'en-PK',
  },
  
  // Dates & Time
  dateTime: {
    timezone: import.meta.env.VITE_TIMEZONE || 'Asia/Karachi',
    dateFormat: import.meta.env.VITE_DATE_FORMAT || 'dd MMM yyyy',
    timeFormat: import.meta.env.VITE_TIME_FORMAT || 'HH:mm',
  },
  
  // Development Mode
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
  
  // Debug Mode
  debug: {
    enabled: import.meta.env.VITE_DEBUG === 'true',
    logLevel: import.meta.env.VITE_LOG_LEVEL || 'info', // 'debug', 'info', 'warn', 'error'
  },
};

// ============================================
// SAMPLE DATA CONFIGURATION
// ============================================

/**
 * Controls whether sample/demo projects should be shown
 * Set to false in production or when you have real data
 */
export const SAMPLE_DATA_CONFIG = {
  enabled: APP_CONFIG.features.showMockProjects,
  
  // Sample Projects - Can be customized or disabled
  sampleProjects: {
    enabled: true,
    count: parseInt(import.meta.env.VITE_SAMPLE_PROJECT_COUNT || '3', 10),
  },
  
  // Sample Reports
  sampleReports: {
    enabled: true,
    count: parseInt(import.meta.env.VITE_SAMPLE_REPORT_COUNT || '5', 10),
  },
};

// ============================================
// NOTIFICATION SETTINGS
// ============================================

export const NOTIFICATION_CONFIG = {
  enabled: APP_CONFIG.features.enableNotifications,
  
  // How long notifications stay visible (milliseconds)
  duration: {
    success: 3000,
    error: 5000,
    warning: 4000,
    info: 3000,
  },
  
  // Maximum notifications to show at once
  maxVisible: 3,
  
  // Position on screen
  position: (import.meta.env.VITE_NOTIFICATION_POSITION || 'top-right') as 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left',
};

// ============================================
// THEME SETTINGS
// ============================================

export const THEME_CONFIG = {
  defaultTheme: (import.meta.env.VITE_DEFAULT_THEME || 'light') as 'light' | 'dark' | 'auto',
  allowThemeSwitch: import.meta.env.VITE_ALLOW_THEME_SWITCH !== 'false',
};

// ============================================
// LANGUAGE SETTINGS
// ============================================

export const LANGUAGE_CONFIG = {
  defaultLanguage: import.meta.env.VITE_DEFAULT_LANGUAGE || 'en',
  supportedLanguages: ['en', 'ur'], // English, Urdu
  allowLanguageSwitch: import.meta.env.VITE_ALLOW_LANGUAGE_SWITCH !== 'false',
};

// ============================================
// SOCIAL & CONTACT
// ============================================

export const CONTACT_CONFIG = {
  email: import.meta.env.VITE_CONTACT_EMAIL || 'support@paktransparent.gov.pk',
  phone: import.meta.env.VITE_CONTACT_PHONE || '+92-51-9000000',
  address: import.meta.env.VITE_CONTACT_ADDRESS || 'Islamabad, Pakistan',
  
  social: {
    twitter: import.meta.env.VITE_SOCIAL_TWITTER || '',
    facebook: import.meta.env.VITE_SOCIAL_FACEBOOK || '',
    linkedin: import.meta.env.VITE_SOCIAL_LINKEDIN || '',
  },
};

// ============================================
// ANALYTICS
// ============================================

export const ANALYTICS_CONFIG = {
  enabled: APP_CONFIG.features.enableAnalytics && APP_CONFIG.isProduction,
  googleAnalyticsId: import.meta.env.VITE_GA_ID || '',
  trackPageViews: true,
  trackEvents: true,
};

// ============================================
// SECURITY
// ============================================

export const SECURITY_CONFIG = {
  // Password Requirements
  password: {
    minLength: parseInt(import.meta.env.VITE_PASSWORD_MIN_LENGTH || '8', 10),
    requireUppercase: import.meta.env.VITE_PASSWORD_REQUIRE_UPPERCASE !== 'false',
    requireLowercase: import.meta.env.VITE_PASSWORD_REQUIRE_LOWERCASE !== 'false',
    requireNumbers: import.meta.env.VITE_PASSWORD_REQUIRE_NUMBERS !== 'false',
    requireSpecialChars: import.meta.env.VITE_PASSWORD_REQUIRE_SPECIAL !== 'false',
  },
  
  // Session
  maxLoginAttempts: parseInt(import.meta.env.VITE_MAX_LOGIN_ATTEMPTS || '5', 10),
  lockoutDuration: parseInt(import.meta.env.VITE_LOCKOUT_DURATION || '900000', 10), // 15 minutes
};

// ============================================
// EXPORTS
// ============================================

// Export everything as a single config object
export default {
  app: APP_CONFIG,
  sampleData: SAMPLE_DATA_CONFIG,
  notification: NOTIFICATION_CONFIG,
  theme: THEME_CONFIG,
  language: LANGUAGE_CONFIG,
  contact: CONTACT_CONFIG,
  analytics: ANALYTICS_CONFIG,
  security: SECURITY_CONFIG,
};
