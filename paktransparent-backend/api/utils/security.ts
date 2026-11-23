/**
 * Security Utilities
 * Provides functions for secure data handling, XSS prevention, and input sanitization
 */

/**
 * Sanitize HTML to prevent XSS attacks
 */
export const sanitizeHTML = (html: string): string => {
  const div = document.createElement('div');
  div.textContent = html;
  return div.innerHTML;
};

/**
 * Escape special characters in user input
 */
export const escapeHTML = (text: string): string => {
  const map: Record<string, string> = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
  };
  return text.replace(/[&<>"'/]/g, (char) => map[char]);
};

/**
 * Validate and sanitize file uploads
 */
export const validateFile = (
  file: File,
  options: {
    maxSize?: number;
    allowedTypes?: string[];
    allowedExtensions?: string[];
  } = {}
): { valid: boolean; error?: string } => {
  const {
    maxSize = 50 * 1024 * 1024, // 50MB default
    allowedTypes = [],
    allowedExtensions = [],
  } = options;

  // Check file size
  if (file.size > maxSize) {
    return {
      valid: false,
      error: `File size exceeds ${Math.round(maxSize / 1024 / 1024)}MB limit`,
    };
  }

  // Check file type
  if (allowedTypes.length > 0 && !allowedTypes.includes(file.type)) {
    return {
      valid: false,
      error: 'File type not allowed',
    };
  }

  // Check file extension
  if (allowedExtensions.length > 0) {
    const extension = file.name.split('.').pop()?.toLowerCase();
    if (!extension || !allowedExtensions.includes(extension)) {
      return {
        valid: false,
        error: 'File extension not allowed',
      };
    }
  }

  return { valid: true };
};

/**
 * Generate secure random string
 */
export const generateSecureToken = (length: number = 32): string => {
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  return Array.from(array, (byte) => byte.toString(16).padStart(2, '0')).join('');
};

/**
 * Hash sensitive data (client-side, for additional security layer)
 */
export const hashData = async (data: string): Promise<string> => {
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(data);
  const hashBuffer = await crypto.subtle.digest('SHA-256', dataBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((byte) => byte.toString(16).padStart(2, '0')).join('');
};

/**
 * Prevent timing attacks when comparing sensitive strings
 */
export const secureCompare = (a: string, b: string): boolean => {
  if (a.length !== b.length) {
    return false;
  }

  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }

  return result === 0;
};

/**
 * Mask sensitive data for display (e.g., CNIC, phone numbers)
 */
export const maskSensitiveData = (
  data: string,
  type: 'cnic' | 'phone' | 'email' | 'custom',
  visibleChars: number = 4
): string => {
  if (!data) return '';

  switch (type) {
    case 'cnic':
      // Show only last 4 digits: XXXXX-XXXXXXX-1234
      return data.replace(/\d(?=\d{4})/g, 'X');

    case 'phone':
      // Show only last 4 digits: +92-XXX-XXXX567
      return data.replace(/\d(?=\d{4})/g, 'X');

    case 'email':
      // Show first char and domain: a****@example.com
      const [username, domain] = data.split('@');
      return `${username[0]}${'*'.repeat(username.length - 1)}@${domain}`;

    case 'custom':
      // Show first and last N characters
      if (data.length <= visibleChars * 2) {
        return '*'.repeat(data.length);
      }
      const start = data.slice(0, visibleChars);
      const end = data.slice(-visibleChars);
      const masked = '*'.repeat(data.length - visibleChars * 2);
      return `${start}${masked}${end}`;

    default:
      return data;
  }
};

/**
 * Rate limiting helper (client-side throttle)
 */
export const createRateLimiter = (maxCalls: number, timeWindow: number) => {
  const calls: number[] = [];

  return (): boolean => {
    const now = Date.now();
    const windowStart = now - timeWindow;

    // Remove old calls outside time window
    while (calls.length > 0 && calls[0] < windowStart) {
      calls.shift();
    }

    // Check if limit exceeded
    if (calls.length >= maxCalls) {
      return false;
    }

    calls.push(now);
    return true;
  };
};

/**
 * Secure localStorage wrapper with encryption awareness
 */
export const secureStorage = {
  set: (key: string, value: unknown): void => {
    try {
      const serialized = JSON.stringify(value);
      localStorage.setItem(key, serialized);
    } catch (error) {
      console.error('Failed to save to localStorage:', error);
    }
  },

  get: <T>(key: string, defaultValue?: T): T | null => {
    try {
      const item = localStorage.getItem(key);
      if (!item) return defaultValue ?? null;
      return JSON.parse(item) as T;
    } catch (error) {
      console.error('Failed to read from localStorage:', error);
      return defaultValue ?? null;
    }
  },

  remove: (key: string): void => {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Failed to remove from localStorage:', error);
    }
  },

  clear: (): void => {
    try {
      localStorage.clear();
    } catch (error) {
      console.error('Failed to clear localStorage:', error);
    }
  },
};

/**
 * Content Security Policy violation reporter
 */
export const setupCSPReporting = (): void => {
  document.addEventListener('securitypolicyviolation', (e) => {
    console.error('CSP Violation:', {
      blockedURI: e.blockedURI,
      violatedDirective: e.violatedDirective,
      originalPolicy: e.originalPolicy,
    });

    // In production, send to logging service
    if (process.env.NODE_ENV === 'production') {
      // sendToLoggingService(e);
    }
  });
};

/**
 * Prevent click jacking
 */
export const preventClickJacking = (): void => {
  if (window.self !== window.top) {
    // Page is in an iframe
    window.top!.location = window.self.location;
  }
};

/**
 * Input validation with length limits to prevent DoS
 */
export const validateInputLength = (
  input: string,
  maxLength: number = 10000
): { valid: boolean; error?: string } => {
  if (input.length > maxLength) {
    return {
      valid: false,
      error: `Input exceeds maximum length of ${maxLength} characters`,
    };
  }
  return { valid: true };
};
