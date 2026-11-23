/**
 * Validation Utilities
 * 
 * Professional-grade validation functions for government-level system
 * All functions return { isValid: boolean, error?: string }
 */

// ============================================
// TYPES
// ============================================

export interface ValidationResult {
  isValid: boolean;
  error?: string;
}

export interface PasswordStrength {
  score: number; // 0-5
  feedback: string;
  hasLength: boolean;
  hasUppercase: boolean;
  hasLowercase: boolean;
  hasNumber: boolean;
  hasSpecial: boolean;
}

// ============================================
// CNIC VALIDATION (Pakistan National ID Card)
// ============================================

/**
 * Validates Pakistani CNIC format: XXXXX-XXXXXXX-X (13 digits)
 * 
 * Rules:
 * - Must be exactly 13 digits
 * - Format: XXXXX-XXXXXXX-X or XXXXXXXXXXXXX
 * - First 5 digits: Area code
 * - Next 7 digits: Serial number + Date of birth encoded
 * - Last digit: Check digit
 * 
 * @param cnic - CNIC number to validate
 * @returns ValidationResult
 */
export const validateCNIC = (cnic: string): ValidationResult => {
  if (!cnic) {
    return {
      isValid: false,
      error: 'CNIC is required',
    };
  }

  // Remove hyphens and spaces
  const cleanCNIC = cnic.replace(/[-\s]/g, '');

  // Check if it contains only digits
  if (!/^\d+$/.test(cleanCNIC)) {
    return {
      isValid: false,
      error: 'CNIC must contain only numbers',
    };
  }

  // Check length
  if (cleanCNIC.length !== 13) {
    return {
      isValid: false,
      error: 'CNIC must be exactly 13 digits',
    };
  }

  // Validate format (with or without hyphens)
  const cnicRegex = /^(\d{5})-?(\d{7})-?(\d{1})$/;
  if (!cnicRegex.test(cnic.replace(/\s/g, ''))) {
    return {
      isValid: false,
      error: 'Invalid CNIC format. Use: XXXXX-XXXXXXX-X or XXXXXXXXXXXXX',
    };
  }

  // Extract gender (last digit before check digit)
  const genderDigit = parseInt(cleanCNIC[12]);
  if (genderDigit < 1 || genderDigit > 9) {
    return {
      isValid: false,
      error: 'Invalid CNIC check digit',
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Formats CNIC with hyphens
 */
export const formatCNIC = (cnic: string): string => {
  const clean = cnic.replace(/[-\s]/g, '');
  if (clean.length === 13) {
    return `${clean.slice(0, 5)}-${clean.slice(5, 12)}-${clean.slice(12)}`;
  }
  return cnic;
};

/**
 * Extract gender from CNIC
 */
export const getCNICGender = (cnic: string): 'male' | 'female' | null => {
  const clean = cnic.replace(/[-\s]/g, '');
  if (clean.length !== 13) return null;
  
  const genderDigit = parseInt(clean[12]);
  return genderDigit % 2 === 0 ? 'female' : 'male';
};

// ============================================
// PASSWORD VALIDATION
// ============================================

/**
 * Validates password strength with comprehensive feedback
 * 
 * Requirements (Government Security Standard):
 * - Minimum 8 characters
 * - At least 1 uppercase letter (A-Z)
 * - At least 1 lowercase letter (a-z)
 * - At least 1 number (0-9)
 * - At least 1 special character (!@#$%^&* etc.)
 * 
 * @param password - Password to validate
 * @returns PasswordStrength
 */
export const validatePasswordStrength = (password: string): PasswordStrength => {
  const result: PasswordStrength = {
    score: 0,
    feedback: '',
    hasLength: password.length >= 8,
    hasUppercase: /[A-Z]/.test(password),
    hasLowercase: /[a-z]/.test(password),
    hasNumber: /\d/.test(password),
    hasSpecial: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
  };

  // Calculate score
  if (result.hasLength) result.score++;
  if (result.hasUppercase) result.score++;
  if (result.hasLowercase) result.score++;
  if (result.hasNumber) result.score++;
  if (result.hasSpecial) result.score++;

  // Additional points for length
  if (password.length >= 12) result.score++;

  // Penalty for common patterns
  if (/^(.)\1+$/.test(password)) result.score = Math.max(0, result.score - 2); // All same character
  if (/^(012|123|234|345|456|567|678|789|890)/.test(password)) result.score = Math.max(0, result.score - 1); // Sequential numbers

  // Generate feedback
  if (result.score === 0) {
    result.feedback = 'Very weak - not acceptable';
  } else if (result.score <= 2) {
    result.feedback = 'Weak - add more complexity';
  } else if (result.score === 3) {
    result.feedback = 'Fair - consider making it stronger';
  } else if (result.score === 4) {
    result.feedback = 'Good - meets requirements';
  } else if (result.score === 5) {
    result.feedback = 'Strong - excellent password';
  } else {
    result.feedback = 'Very strong - secure password';
  }

  return result;
};

/**
 * Validates password meets minimum requirements
 */
export const validatePassword = (password: string): ValidationResult => {
  if (!password) {
    return {
      isValid: false,
      error: 'Password is required',
    };
  }

  const strength = validatePasswordStrength(password);

  if (!strength.hasLength) {
    return {
      isValid: false,
      error: 'Password must be at least 8 characters long',
    };
  }

  if (!strength.hasUppercase) {
    return {
      isValid: false,
      error: 'Password must contain at least one uppercase letter',
    };
  }

  if (!strength.hasLowercase) {
    return {
      isValid: false,
      error: 'Password must contain at least one lowercase letter',
    };
  }

  if (!strength.hasNumber) {
    return {
      isValid: false,
      error: 'Password must contain at least one number',
    };
  }

  if (!strength.hasSpecial) {
    return {
      isValid: false,
      error: 'Password must contain at least one special character (!@#$%^&* etc.)',
    };
  }

  if (strength.score < 4) {
    return {
      isValid: false,
      error: 'Password is too weak. Please make it stronger.',
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// COMMON WEAK PASSWORDS BLACKLIST
// ============================================

const COMMON_PASSWORDS = [
  'password', 'password123', '12345678', '123456789', 'qwerty', 'abc123',
  'monkey', '1234567', 'letmein', 'trustno1', 'dragon', 'baseball',
  'iloveyou', 'master', 'sunshine', 'ashley', 'bailey', 'passw0rd',
  'shadow', '123123', '654321', 'superman', 'qazwsx', 'michael',
  'football', 'pakistan', 'admin', 'admin123', 'root', 'toor'
];

export const isCommonPassword = (password: string): boolean => {
  return COMMON_PASSWORDS.includes(password.toLowerCase());
};

// ============================================
// EMAIL VALIDATION
// ============================================

/**
 * Validates email format
 * Follows RFC 5322 standard
 */
export const validateEmail = (email: string): ValidationResult => {
  if (!email) {
    return {
      isValid: false,
      error: 'Email is required',
    };
  }

  // Comprehensive email regex
  const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;

  if (!emailRegex.test(email)) {
    return {
      isValid: false,
      error: 'Please enter a valid email address',
    };
  }

  // Additional checks
  if (email.length > 254) {
    return {
      isValid: false,
      error: 'Email address is too long',
    };
  }

  const [localPart, domain] = email.split('@');
  
  if (localPart.length > 64) {
    return {
      isValid: false,
      error: 'Email local part is too long',
    };
  }

  if (!domain.includes('.')) {
    return {
      isValid: false,
      error: 'Email domain must contain a dot',
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// PHONE NUMBER VALIDATION (Pakistan)
// ============================================

/**
 * Validates Pakistan phone number
 * Formats: +92-XXX-XXXXXXX or 03XX-XXXXXXX
 */
export const validatePhoneNumber = (phone: string): ValidationResult => {
  if (!phone) {
    return {
      isValid: false,
      error: 'Phone number is required',
    };
  }

  // Remove spaces, hyphens, and parentheses
  const cleanPhone = phone.replace(/[\s\-()]/g, '');

  // Pakistan mobile format: +923XXXXXXXXX or 03XXXXXXXXX
  const mobileRegex = /^(\+92|0)?3\d{9}$/;
  
  // Pakistan landline format: +92XXXXXXXXXX or 0XXXXXXXXXX
  const landlineRegex = /^(\+92|0)?[2-5]\d{8,9}$/;

  if (!mobileRegex.test(cleanPhone) && !landlineRegex.test(cleanPhone)) {
    return {
      isValid: false,
      error: 'Please enter a valid Pakistan phone number',
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Format phone number for display
 */
export const formatPhoneNumber = (phone: string): string => {
  const clean = phone.replace(/[\s\-()]/g, '');
  
  // Mobile: +92-3XX-XXXXXXX
  if (/^(\+92|0)?3\d{9}$/.test(clean)) {
    const digits = clean.replace(/^\+92|^0/, '');
    return `+92-${digits.slice(0, 3)}-${digits.slice(3)}`;
  }

  // Landline: +92-XX-XXXXXXXX
  if (/^(\+92|0)?[2-5]\d{8,9}$/.test(clean)) {
    const digits = clean.replace(/^\+92|^0/, '');
    return `+92-${digits.slice(0, 2)}-${digits.slice(2)}`;
  }

  return phone;
};

// ============================================
// NUMBER VALIDATION
// ============================================

/**
 * Validates positive number
 */
export const validatePositiveNumber = (value: string | number, fieldName: string = 'Value'): ValidationResult => {
  const num = typeof value === 'string' ? parseFloat(value) : value;

  if (isNaN(num)) {
    return {
      isValid: false,
      error: `${fieldName} must be a valid number`,
    };
  }

  if (num < 0) {
    return {
      isValid: false,
      error: `${fieldName} must be positive`,
    };
  }

  if (!isFinite(num)) {
    return {
      isValid: false,
      error: `${fieldName} must be a finite number`,
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Validates budget amount
 */
export const validateBudget = (amount: string | number): ValidationResult => {
  const num = typeof amount === 'string' ? parseFloat(amount) : amount;

  const positiveCheck = validatePositiveNumber(num, 'Budget');
  if (!positiveCheck.isValid) {
    return positiveCheck;
  }

  // Minimum budget: 1,000 PKR
  if (num < 1000) {
    return {
      isValid: false,
      error: 'Budget must be at least PKR 1,000',
    };
  }

  // Maximum budget: 1 trillion PKR (reasonable government project limit)
  if (num > 1000000000000) {
    return {
      isValid: false,
      error: 'Budget exceeds maximum allowed amount',
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// TEXT VALIDATION
// ============================================

/**
 * Validates required text field
 */
export const validateRequired = (value: string, fieldName: string = 'Field'): ValidationResult => {
  if (!value || value.trim().length === 0) {
    return {
      isValid: false,
      error: `${fieldName} is required`,
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Validates text length
 */
export const validateLength = (
  value: string,
  min: number,
  max: number,
  fieldName: string = 'Field'
): ValidationResult => {
  const length = value.trim().length;

  if (length < min) {
    return {
      isValid: false,
      error: `${fieldName} must be at least ${min} characters`,
    };
  }

  if (length > max) {
    return {
      isValid: false,
      error: `${fieldName} must not exceed ${max} characters`,
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Validates alphanumeric with spaces
 */
export const validateAlphanumeric = (value: string, fieldName: string = 'Field'): ValidationResult => {
  if (!value) {
    return { isValid: true }; // Empty is ok if not required
  }

  if (!/^[a-zA-Z0-9\s]+$/.test(value)) {
    return {
      isValid: false,
      error: `${fieldName} can only contain letters, numbers, and spaces`,
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// DATE VALIDATION
// ============================================

/**
 * Validates date is in the future
 */
export const validateFutureDate = (date: Date | string, fieldName: string = 'Date'): ValidationResult => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;

  if (isNaN(dateObj.getTime())) {
    return {
      isValid: false,
      error: `${fieldName} is not a valid date`,
    };
  }

  if (dateObj < new Date()) {
    return {
      isValid: false,
      error: `${fieldName} must be in the future`,
    };
  }

  return {
    isValid: true,
  };
};

/**
 * Validates date range
 */
export const validateDateRange = (
  startDate: Date | string,
  endDate: Date | string
): ValidationResult => {
  const start = typeof startDate === 'string' ? new Date(startDate) : startDate;
  const end = typeof endDate === 'string' ? new Date(endDate) : endDate;

  if (isNaN(start.getTime())) {
    return {
      isValid: false,
      error: 'Start date is not valid',
    };
  }

  if (isNaN(end.getTime())) {
    return {
      isValid: false,
      error: 'End date is not valid',
    };
  }

  if (start >= end) {
    return {
      isValid: false,
      error: 'End date must be after start date',
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// FILE VALIDATION
// ============================================

/**
 * Validates file upload
 */
export const validateFile = (
  file: File,
  maxSize: number = 50 * 1024 * 1024, // 50MB default
  allowedTypes: string[] = []
): ValidationResult => {
  if (!file) {
    return {
      isValid: false,
      error: 'Please select a file',
    };
  }

  // Check file size
  if (file.size > maxSize) {
    return {
      isValid: false,
      error: `File size must not exceed ${Math.round(maxSize / 1024 / 1024)}MB`,
    };
  }

  // Check file type
  if (allowedTypes.length > 0 && !allowedTypes.includes(file.type)) {
    return {
      isValid: false,
      error: 'File type is not allowed',
    };
  }

  return {
    isValid: true,
  };
};

// ============================================
// SANITIZATION
// ============================================

/**
 * Sanitize HTML to prevent XSS
 */
export const sanitizeHTML = (html: string): string => {
  const div = document.createElement('div');
  div.textContent = html;
  return div.innerHTML;
};

/**
 * Sanitize user input (remove potentially dangerous characters)
 */
export const sanitizeInput = (input: string): string => {
  return input
    .trim()
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
    .replace(/on\w+\s*=\s*["'][^"']*["']/gi, '')
    .replace(/javascript:/gi, '');
};

// ============================================
// EXPORTS
// ============================================

export default {
  validateCNIC,
  formatCNIC,
  getCNICGender,
  validatePassword,
  validatePasswordStrength,
  isCommonPassword,
  validateEmail,
  validatePhoneNumber,
  formatPhoneNumber,
  validatePositiveNumber,
  validateBudget,
  validateRequired,
  validateLength,
  validateAlphanumeric,
  validateFutureDate,
  validateDateRange,
  validateFile,
  sanitizeHTML,
  sanitizeInput,
};
