/**
 * Security Service
 * 
 * Government-level security enhancements
 * - Password hashing (bcrypt simulation for demo)
 * - Session management with expiry
 * - CSRF token management
 * - Rate limiting
 * - Input sanitization
 * - Audit logging
 */

import CryptoJS from 'crypto-js';

// ===========================
// PASSWORD SECURITY
// ===========================

/**
 * Hash password using SHA-256 (simulated bcrypt for demo)
 * In production, use actual bcrypt library
 */
export const hashPassword = async (password: string): Promise<string> => {
  // Add salt for better security
  const salt = CryptoJS.lib.WordArray.random(128/8).toString();
  const hash = CryptoJS.SHA256(password + salt).toString();
  return `${salt}:${hash}`;
};

/**
 * Verify password against hash
 */
export const verifyPassword = async (password: string, hashedPassword: string): Promise<boolean> => {
  const [salt, hash] = hashedPassword.split(':');
  const computedHash = CryptoJS.SHA256(password + salt).toString();
  return computedHash === hash;
};

// ===========================
// SESSION MANAGEMENT
// ===========================

export interface SessionData {
  token: string;
  userId: string;
  expiresAt: number;
  createdAt: number;
  lastActivity: number;
}

const SESSION_DURATION = 24 * 60 * 60 * 1000; // 24 hours
const INACTIVITY_TIMEOUT = 30 * 60 * 1000; // 30 minutes

/**
 * Create a new session
 */
export const createSession = (userId: string): SessionData => {
  const now = Date.now();
  return {
    token: generateSecureToken(),
    userId,
    expiresAt: now + SESSION_DURATION,
    createdAt: now,
    lastActivity: now,
  };
};

/**
 * Validate session
 */
export const validateSession = (session: SessionData | null): boolean => {
  if (!session) return false;
  
  const now = Date.now();
  
  // Check if session expired
  if (now > session.expiresAt) {
    return false;
  }
  
  // Check inactivity timeout
  if (now - session.lastActivity > INACTIVITY_TIMEOUT) {
    return false;
  }
  
  return true;
};

/**
 * Update session activity
 */
export const updateSessionActivity = (session: SessionData): SessionData => {
  return {
    ...session,
    lastActivity: Date.now(),
  };
};

/**
 * Get session time remaining
 */
export const getSessionTimeRemaining = (session: SessionData): number => {
  return Math.max(0, session.expiresAt - Date.now());
};

// ===========================
// CSRF PROTECTION
// ===========================

const CSRF_TOKEN_KEY = 'csrf_token';

/**
 * Generate CSRF token
 */
export const generateCSRFToken = (): string => {
  const token = generateSecureToken();
  sessionStorage.setItem(CSRF_TOKEN_KEY, token);
  return token;
};

/**
 * Validate CSRF token
 */
export const validateCSRFToken = (token: string): boolean => {
  const storedToken = sessionStorage.getItem(CSRF_TOKEN_KEY);
  return storedToken === token;
};

/**
 * Get current CSRF token
 */
export const getCSRFToken = (): string | null => {
  return sessionStorage.getItem(CSRF_TOKEN_KEY);
};

// ===========================
// RATE LIMITING
// ===========================

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();

/**
 * Check rate limit
 * @param key - Unique identifier (e.g., userId, IP)
 * @param maxRequests - Maximum requests allowed
 * @param windowMs - Time window in milliseconds
 */
export const checkRateLimit = (
  key: string,
  maxRequests: number = 100,
  windowMs: number = 60000
): { allowed: boolean; remaining: number; resetAt: number } => {
  const now = Date.now();
  const entry = rateLimitStore.get(key);
  
  // No entry or expired, create new
  if (!entry || now > entry.resetAt) {
    const newEntry: RateLimitEntry = {
      count: 1,
      resetAt: now + windowMs,
    };
    rateLimitStore.set(key, newEntry);
    return {
      allowed: true,
      remaining: maxRequests - 1,
      resetAt: newEntry.resetAt,
    };
  }
  
  // Increment count
  entry.count++;
  
  if (entry.count > maxRequests) {
    return {
      allowed: false,
      remaining: 0,
      resetAt: entry.resetAt,
    };
  }
  
  return {
    allowed: true,
    remaining: maxRequests - entry.count,
    resetAt: entry.resetAt,
  };
};

/**
 * Reset rate limit for a key
 */
export const resetRateLimit = (key: string): void => {
  rateLimitStore.delete(key);
};

// ===========================
// INPUT SANITIZATION
// ===========================

/**
 * Sanitize HTML to prevent XSS
 */
export const sanitizeHTML = (input: string): string => {
  const div = document.createElement('div');
  div.textContent = input;
  return div.innerHTML;
};

/**
 * Sanitize user input (comprehensive)
 */
export const sanitizeInput = (input: string): string => {
  return input
    .trim()
    .replace(/[<>]/g, '') // Remove potential HTML tags
    .replace(/javascript:/gi, '') // Remove javascript: protocol
    .replace(/on\w+\s*=/gi, ''); // Remove event handlers
};

/**
 * Validate email format
 */
export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Validate CNIC format (Pakistan)
 */
export const isValidCNIC = (cnic: string): boolean => {
  const cnicRegex = /^\d{5}-\d{7}-\d{1}$/;
  return cnicRegex.test(cnic);
};

/**
 * Validate phone number (Pakistan)
 */
export const isValidPhoneNumber = (phone: string): boolean => {
  const phoneRegex = /^(\+92|0)?3\d{9}$/;
  return phoneRegex.test(phone.replace(/[-\s]/g, ''));
};

/**
 * Sanitize file name
 */
export const sanitizeFileName = (fileName: string): string => {
  return fileName
    .replace(/[^a-zA-Z0-9._-]/g, '_')
    .replace(/_{2,}/g, '_')
    .substring(0, 255);
};

// ===========================
// AUDIT LOGGING
// ===========================

export interface AuditLog {
  id: string;
  timestamp: number;
  userId: string;
  action: string;
  resource: string;
  details?: any;
  ipAddress?: string;
  userAgent?: string;
  success: boolean;
}

const AUDIT_LOG_KEY = 'audit_logs';
const MAX_AUDIT_LOGS = 1000;

/**
 * Create audit log entry
 */
export const createAuditLog = (
  userId: string,
  action: string,
  resource: string,
  success: boolean = true,
  details?: any
): AuditLog => {
  const log: AuditLog = {
    id: generateSecureToken(),
    timestamp: Date.now(),
    userId,
    action,
    resource,
    details,
    success,
    userAgent: navigator.userAgent,
  };
  
  // Store in localStorage
  try {
    const logs = getAuditLogs();
    logs.unshift(log);
    
    // Keep only last MAX_AUDIT_LOGS entries
    if (logs.length > MAX_AUDIT_LOGS) {
      logs.splice(MAX_AUDIT_LOGS);
    }
    
    localStorage.setItem(AUDIT_LOG_KEY, JSON.stringify(logs));
  } catch (error) {
    console.error('Failed to store audit log:', error);
  }
  
  return log;
};

/**
 * Get all audit logs
 */
export const getAuditLogs = (): AuditLog[] => {
  try {
    const logs = localStorage.getItem(AUDIT_LOG_KEY);
    return logs ? JSON.parse(logs) : [];
  } catch {
    return [];
  }
};

/**
 * Get audit logs for specific user
 */
export const getUserAuditLogs = (userId: string): AuditLog[] => {
  return getAuditLogs().filter(log => log.userId === userId);
};

/**
 * Clear audit logs
 */
export const clearAuditLogs = (): void => {
  localStorage.removeItem(AUDIT_LOG_KEY);
};

// ===========================
// TOKEN GENERATION
// ===========================

/**
 * Generate secure random token
 */
export const generateSecureToken = (length: number = 32): string => {
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
};

// ===========================
// ACCOUNT LOCKOUT
// ===========================

interface LockoutEntry {
  attempts: number;
  lockedUntil?: number;
}

const lockoutStore = new Map<string, LockoutEntry>();
const MAX_LOGIN_ATTEMPTS = 5;
const LOCKOUT_DURATION = 15 * 60 * 1000; // 15 minutes

/**
 * Record failed login attempt
 */
export const recordFailedLogin = (identifier: string): { locked: boolean; attemptsRemaining: number; lockedUntil?: number } => {
  const entry = lockoutStore.get(identifier) || { attempts: 0 };
  entry.attempts++;
  
  if (entry.attempts >= MAX_LOGIN_ATTEMPTS) {
    entry.lockedUntil = Date.now() + LOCKOUT_DURATION;
    lockoutStore.set(identifier, entry);
    return {
      locked: true,
      attemptsRemaining: 0,
      lockedUntil: entry.lockedUntil,
    };
  }
  
  lockoutStore.set(identifier, entry);
  return {
    locked: false,
    attemptsRemaining: MAX_LOGIN_ATTEMPTS - entry.attempts,
  };
};

/**
 * Check if account is locked
 */
export const isAccountLocked = (identifier: string): { locked: boolean; lockedUntil?: number } => {
  const entry = lockoutStore.get(identifier);
  
  if (!entry || !entry.lockedUntil) {
    return { locked: false };
  }
  
  const now = Date.now();
  
  if (now > entry.lockedUntil) {
    // Lockout expired, reset
    lockoutStore.delete(identifier);
    return { locked: false };
  }
  
  return {
    locked: true,
    lockedUntil: entry.lockedUntil,
  };
};

/**
 * Reset login attempts on successful login
 */
export const resetLoginAttempts = (identifier: string): void => {
  lockoutStore.delete(identifier);
};

// ===========================
// ENCRYPTION (for sensitive data)
// ===========================

const ENCRYPTION_KEY = 'pak-transparent-encryption-key-2024'; // In production, use env variable

/**
 * Encrypt sensitive data
 */
export const encryptData = (data: string): string => {
  return CryptoJS.AES.encrypt(data, ENCRYPTION_KEY).toString();
};

/**
 * Decrypt sensitive data
 */
export const decryptData = (encryptedData: string): string => {
  const bytes = CryptoJS.AES.decrypt(encryptedData, ENCRYPTION_KEY);
  return bytes.toString(CryptoJS.enc.Utf8);
};

// ===========================
// EXPORTS
// ===========================

export default {
  // Password
  hashPassword,
  verifyPassword,
  
  // Session
  createSession,
  validateSession,
  updateSessionActivity,
  getSessionTimeRemaining,
  
  // CSRF
  generateCSRFToken,
  validateCSRFToken,
  getCSRFToken,
  
  // Rate Limiting
  checkRateLimit,
  resetRateLimit,
  
  // Input Sanitization
  sanitizeHTML,
  sanitizeInput,
  isValidEmail,
  isValidCNIC,
  isValidPhoneNumber,
  sanitizeFileName,
  
  // Audit Logging
  createAuditLog,
  getAuditLogs,
  getUserAuditLogs,
  clearAuditLogs,
  
  // Account Lockout
  recordFailedLogin,
  isAccountLocked,
  resetLoginAttempts,
  
  // Encryption
  encryptData,
  decryptData,
  
  // Token
  generateSecureToken,
};
