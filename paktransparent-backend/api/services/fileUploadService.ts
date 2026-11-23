/**
 * File Upload Service
 * 
 * Professional file handling for government-level application
 * - Validates file types and sizes
 * - Converts files to base64 for localStorage persistence
 * - Handles images, documents, and videos
 * - Provides secure file management
 */

export interface UploadedFile {
  id: string;
  name: string;
  size: number;
  type: string;
  mimeType: string;
  url: string; // base64 or external URL
  uploadedAt: Date;
  uploadedBy?: string;
  category?: 'image' | 'document' | 'video' | 'other';
}

export interface FileValidationOptions {
  maxSizeMB?: number;
  allowedTypes?: string[];
  allowedExtensions?: string[];
}

export interface FileValidationResult {
  isValid: boolean;
  error?: string;
}

/**
 * Default file validation rules
 */
const DEFAULT_MAX_SIZE_MB = 50;
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
const ALLOWED_DOCUMENT_TYPES = [
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
];
const ALLOWED_VIDEO_TYPES = ['video/mp4', 'video/webm', 'video/ogg'];

/**
 * Validate file before upload
 */
export const validateFile = (
  file: File,
  options: FileValidationOptions = {}
): FileValidationResult => {
  const {
    maxSizeMB = DEFAULT_MAX_SIZE_MB,
    allowedTypes,
    allowedExtensions,
  } = options;

  // Check file size
  const maxSizeBytes = maxSizeMB * 1024 * 1024;
  if (file.size > maxSizeBytes) {
    return {
      isValid: false,
      error: `File size exceeds ${maxSizeMB}MB limit`,
    };
  }

  // Check file type if specified
  if (allowedTypes && allowedTypes.length > 0) {
    if (!allowedTypes.includes(file.type)) {
      return {
        isValid: false,
        error: 'File type is not allowed',
      };
    }
  }

  // Check file extension if specified
  if (allowedExtensions && allowedExtensions.length > 0) {
    const extension = file.name.split('.').pop()?.toLowerCase();
    if (!extension || !allowedExtensions.includes(`.${extension}`)) {
      return {
        isValid: false,
        error: `File extension must be one of: ${allowedExtensions.join(', ')}`,
      };
    }
  }

  // Check for empty file
  if (file.size === 0) {
    return {
      isValid: false,
      error: 'File is empty',
    };
  }

  return { isValid: true };
};

/**
 * Validate multiple files
 */
export const validateFiles = (
  files: File[],
  options: FileValidationOptions = {}
): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];

  files.forEach((file, index) => {
    const result = validateFile(file, options);
    if (!result.isValid && result.error) {
      errors.push(`${file.name}: ${result.error}`);
    }
  });

  return {
    isValid: errors.length === 0,
    errors,
  };
};

/**
 * Get file category from MIME type
 */
export const getFileCategory = (mimeType: string): UploadedFile['category'] => {
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType.startsWith('video/')) return 'video';
  if (
    mimeType.includes('pdf') ||
    mimeType.includes('document') ||
    mimeType.includes('sheet') ||
    mimeType.includes('text')
  ) {
    return 'document';
  }
  return 'other';
};

/**
 * Get icon name for file type
 */
export const getFileIcon = (mimeType: string): string => {
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType.startsWith('video/')) return 'videocam';
  if (mimeType.includes('pdf')) return 'picture_as_pdf';
  if (mimeType.includes('word')) return 'description';
  if (mimeType.includes('sheet') || mimeType.includes('excel')) return 'table_chart';
  if (mimeType.includes('presentation') || mimeType.includes('powerpoint')) return 'slideshow';
  return 'attach_file';
};

/**
 * Format file size for display
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return `${(bytes / Math.pow(k, i)).toFixed(1)} ${sizes[i]}`;
};

/**
 * Convert File to base64 for storage
 */
export const fileToBase64 = (file: File): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        resolve(reader.result);
      } else {
        reject(new Error('Failed to convert file to base64'));
      }
    };
    
    reader.onerror = () => {
      reject(new Error('Error reading file'));
    };
    
    reader.readAsDataURL(file);
  });
};

/**
 * Upload single file
 */
export const uploadFile = async (
  file: File,
  uploadedBy?: string,
  validationOptions?: FileValidationOptions
): Promise<UploadedFile> => {
  // Validate file
  const validation = validateFile(file, validationOptions);
  if (!validation.isValid) {
    throw new Error(validation.error);
  }

  try {
    // Convert to base64
    const base64 = await fileToBase64(file);

    const uploadedFile: UploadedFile = {
      id: `file_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      name: file.name,
      size: file.size,
      type: file.type,
      mimeType: file.type,
      url: base64,
      uploadedAt: new Date(),
      uploadedBy,
      category: getFileCategory(file.type),
    };

    return uploadedFile;
  } catch (error) {
    throw new Error(`Failed to upload file: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
};

/**
 * Upload multiple files
 */
export const uploadFiles = async (
  files: File[],
  uploadedBy?: string,
  validationOptions?: FileValidationOptions
): Promise<UploadedFile[]> => {
  // Validate all files first
  const validation = validateFiles(files, validationOptions);
  if (!validation.isValid) {
    throw new Error(`File validation failed:\n${validation.errors.join('\n')}`);
  }

  try {
    const uploadPromises = files.map((file) => uploadFile(file, uploadedBy, validationOptions));
    return await Promise.all(uploadPromises);
  } catch (error) {
    throw new Error(`Failed to upload files: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
};

/**
 * Image compression (optional enhancement)
 */
export const compressImage = (
  base64: string,
  maxWidth: number = 1920,
  maxHeight: number = 1080,
  quality: number = 0.8
): Promise<string> => {
  return new Promise((resolve, reject) => {
    const img = new Image();
    
    img.onload = () => {
      const canvas = document.createElement('canvas');
      let { width, height } = img;

      // Calculate new dimensions
      if (width > maxWidth) {
        height = (height * maxWidth) / width;
        width = maxWidth;
      }
      if (height > maxHeight) {
        width = (width * maxHeight) / height;
        height = maxHeight;
      }

      canvas.width = width;
      canvas.height = height;

      const ctx = canvas.getContext('2d');
      if (!ctx) {
        reject(new Error('Could not get canvas context'));
        return;
      }

      ctx.drawImage(img, 0, 0, width, height);

      try {
        const compressed = canvas.toDataURL('image/jpeg', quality);
        resolve(compressed);
      } catch (error) {
        reject(error);
      }
    };

    img.onerror = () => {
      reject(new Error('Failed to load image'));
    };

    img.src = base64;
  });
};

/**
 * Generate thumbnail for image
 */
export const generateThumbnail = (
  base64: string,
  width: number = 200,
  height: number = 200
): Promise<string> => {
  return compressImage(base64, width, height, 0.7);
};

/**
 * Check if file is an image
 */
export const isImage = (mimeType: string): boolean => {
  return ALLOWED_IMAGE_TYPES.includes(mimeType);
};

/**
 * Check if file is a document
 */
export const isDocument = (mimeType: string): boolean => {
  return ALLOWED_DOCUMENT_TYPES.includes(mimeType);
};

/**
 * Check if file is a video
 */
export const isVideo = (mimeType: string): boolean => {
  return ALLOWED_VIDEO_TYPES.includes(mimeType);
};

/**
 * Get safe placeholder image when file is missing or invalid
 */
export const getPlaceholderImage = (type: 'project' | 'user' | 'document' = 'project'): string => {
  // Return a simple SVG placeholder
  const placeholders = {
    project: `data:image/svg+xml,${encodeURIComponent(`
      <svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
        <rect width="400" height="300" fill="#e0e0e0"/>
        <g transform="translate(200, 150)">
          <circle r="40" fill="#9e9e9e"/>
          <path d="M-20,-10 L0,-20 L20,-10 L20,20 L-20,20 Z" fill="#fff"/>
        </g>
      </svg>
    `)}`,
    user: `data:image/svg+xml,${encodeURIComponent(`
      <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
        <circle cx="100" cy="100" r="100" fill="#e0e0e0"/>
        <circle cx="100" cy="80" r="35" fill="#9e9e9e"/>
        <path d="M 40 180 Q 100 120 160 180" fill="#9e9e9e"/>
      </svg>
    `)}`,
    document: `data:image/svg+xml,${encodeURIComponent(`
      <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
        <rect width="200" height="200" fill="#e0e0e0"/>
        <rect x="50" y="40" width="100" height="120" fill="#fff" stroke="#9e9e9e" stroke-width="2"/>
        <line x1="65" y1="70" x2="135" y2="70" stroke="#9e9e9e" stroke-width="2"/>
        <line x1="65" y1="90" x2="135" y2="90" stroke="#9e9e9e" stroke-width="2"/>
        <line x1="65" y1="110" x2="135" y2="110" stroke="#9e9e9e" stroke-width="2"/>
      </svg>
    `)}`,
  };

  return placeholders[type];
};

/**
 * Export all file management functions
 */
export default {
  validateFile,
  validateFiles,
  getFileCategory,
  getFileIcon,
  formatFileSize,
  fileToBase64,
  uploadFile,
  uploadFiles,
  compressImage,
  generateThumbnail,
  isImage,
  isDocument,
  isVideo,
  getPlaceholderImage,
};
