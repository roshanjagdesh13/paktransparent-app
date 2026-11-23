import { format as formatDate, parseISO } from 'date-fns';
import { CURRENCY_SYMBOL, DATE_FORMAT, DATE_TIME_FORMAT } from '@/constants';

/**
 * Format currency value
 */
export const formatCurrency = (
  amount: number,
  showSymbol: boolean = true,
  decimals: number = 2
): string => {
  const formatted = new Intl.NumberFormat('en-PK', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  }).format(amount);

  return showSymbol ? `${CURRENCY_SYMBOL} ${formatted}` : formatted;
};

/**
 * Format large numbers with suffixes (K, M, B, T)
 */
export const formatCompactNumber = (num: number, decimals: number = 1): string => {
  if (num >= 1e12) {
    return `${(num / 1e12).toFixed(decimals)}T`;
  }
  if (num >= 1e9) {
    return `${(num / 1e9).toFixed(decimals)}B`;
  }
  if (num >= 1e6) {
    return `${(num / 1e6).toFixed(decimals)}M`;
  }
  if (num >= 1e3) {
    return `${(num / 1e3).toFixed(decimals)}K`;
  }
  return num.toString();
};

/**
 * Format currency in compact form
 */
export const formatCompactCurrency = (amount: number, decimals: number = 1): string => {
  return `${CURRENCY_SYMBOL} ${formatCompactNumber(amount, decimals)}`;
};

/**
 * Format percentage
 */
export const formatPercentage = (value: number, decimals: number = 1): string => {
  return `${value.toFixed(decimals)}%`;
};

/**
 * Format date
 */
export const formatDateStr = (
  date: Date | string,
  formatStr: string = DATE_FORMAT
): string => {
  const dateObj = typeof date === 'string' ? parseISO(date) : date;
  return formatDate(dateObj, formatStr);
};

/**
 * Format date with time
 */
export const formatDateTime = (date: Date | string): string => {
  return formatDateStr(date, DATE_TIME_FORMAT);
};

/**
 * Format file size
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';

  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
};

/**
 * Format phone number
 */
export const formatPhoneNumber = (phone: string): string => {
  // Remove all non-numeric characters
  const cleaned = phone.replace(/\D/g, '');
  
  // Format as +92-XXX-XXXXXXX
  if (cleaned.startsWith('92')) {
    return `+${cleaned.slice(0, 2)}-${cleaned.slice(2, 5)}-${cleaned.slice(5)}`;
  }
  
  return phone;
};

/**
 * Format CNIC
 */
export const formatCNIC = (cnic: string): string => {
  // Remove all non-numeric characters
  const cleaned = cnic.replace(/\D/g, '');
  
  // Format as XXXXX-XXXXXXX-X
  if (cleaned.length === 13) {
    return `${cleaned.slice(0, 5)}-${cleaned.slice(5, 12)}-${cleaned.slice(12)}`;
  }
  
  return cnic;
};

/**
 * Truncate text
 */
export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength)}...`;
};

/**
 * Get initials from name
 */
export const getInitials = (name: string): string => {
  return name
    .split(' ')
    .map(part => part[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
};

/**
 * Format time ago
 */
export const formatTimeAgo = (date: Date | string): string => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  const seconds = Math.floor((new Date().getTime() - dateObj.getTime()) / 1000);

  let interval = seconds / 31536000;
  if (interval > 1) return Math.floor(interval) + ' years ago';

  interval = seconds / 2592000;
  if (interval > 1) return Math.floor(interval) + ' months ago';

  interval = seconds / 86400;
  if (interval > 1) return Math.floor(interval) + ' days ago';

  interval = seconds / 3600;
  if (interval > 1) return Math.floor(interval) + ' hours ago';

  interval = seconds / 60;
  if (interval > 1) return Math.floor(interval) + ' minutes ago';

  return Math.floor(seconds) + ' seconds ago';
};
