import { LogLevel } from "../types/index.js";

/**
 * Interface for logging system
 * Provides structured logging with different levels
 */
export interface Logger {
  /**
   * Logs an informational message
   * @param message Message to log
   * @param context Optional context object
   */
  info(message: string, context?: object): void;

  /**
   * Logs a warning message
   * @param message Message to log
   * @param context Optional context object
   */
  warn(message: string, context?: object): void;

  /**
   * Logs an error message
   * @param message Message to log
   * @param error Optional error object
   */
  error(message: string, error?: Error): void;

  /**
   * Logs a success message
   * @param message Message to log
   * @param context Optional context object
   */
  success(message: string, context?: object): void;

  /**
   * Logs a debug message
   * @param message Message to log
   * @param context Optional context object
   */
  debug(message: string, context?: object): void;

  /**
   * Sets the current log level
   * @param level Log level to set
   */
  setLevel(level: LogLevel): void;

  /**
   * Gets the current log level
   * @returns Current log level
   */
  getLevel(): LogLevel;
}
