/**
 * Logging Utility
 * Provides structured logging for development and production
 */

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  data?: unknown;
  stack?: string;
}

class Logger {
  private isDevelopment: boolean;

  constructor() {
    this.isDevelopment = import.meta.env.DEV;
  }

  private formatMessage(level: LogLevel, message: string, data?: unknown): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      level,
      message,
      data,
    };
  }

  private shouldLog(level: LogLevel): boolean {
    // In production, only log warnings and errors
    if (!this.isDevelopment && (level === 'debug' || level === 'info')) {
      return false;
    }
    return true;
  }

  private sendToService(entry: LogEntry): void {
    // In production, send logs to external service (e.g., Sentry, LogRocket)
    if (!this.isDevelopment) {
      // Example: Send to logging service
      // fetch('/api/logs', {
      //   method: 'POST',
      //   body: JSON.stringify(entry),
      // });
    }
  }

  debug(message: string, data?: unknown): void {
    if (!this.shouldLog('debug')) return;
    
    const entry = this.formatMessage('debug', message, data);
    console.debug(`[DEBUG] ${message}`, data);
  }

  info(message: string, data?: unknown): void {
    if (!this.shouldLog('info')) return;
    
    const entry = this.formatMessage('info', message, data);
    console.info(`[INFO] ${message}`, data);
  }

  warn(message: string, data?: unknown): void {
    if (!this.shouldLog('warn')) return;
    
    const entry = this.formatMessage('warn', message, data);
    console.warn(`[WARN] ${message}`, data);
    this.sendToService(entry);
  }

  error(message: string, error?: Error | unknown, data?: unknown): void {
    const entry: LogEntry = {
      ...this.formatMessage('error', message, data),
      stack: error instanceof Error ? error.stack : undefined,
    };

    console.error(`[ERROR] ${message}`, error, data);
    this.sendToService(entry);
  }

  // Log user actions for audit trail
  auditLog(action: string, userId: string, details?: unknown): void {
    const entry = {
      timestamp: new Date().toISOString(),
      action,
      userId,
      details,
    };

    if (this.isDevelopment) {
      console.log(`[AUDIT] ${action}`, entry);
    }

    // In production, send to audit log service
    // auditService.log(entry);
  }

  // Log API calls
  apiLog(method: string, url: string, status: number, duration: number): void {
    const entry = {
      timestamp: new Date().toISOString(),
      method,
      url,
      status,
      duration,
    };

    if (this.isDevelopment) {
      console.log(`[API] ${method} ${url} - ${status} (${duration}ms)`);
    }

    // In production, send to API monitoring service
  }
}

// Export singleton instance
export const logger = new Logger();

// Export types
export type { LogLevel, LogEntry };
