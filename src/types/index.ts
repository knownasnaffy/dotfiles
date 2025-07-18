// Core type definitions for the dotfiles manager

export interface TemplateConfig {
  name: string;
  description: string;
  packages: string[];
  symlinks: string[];
  postInstallTasks: string[];
  requiresPrivatePackages?: boolean;
}

export interface PackageDefinitions {
  [packageName: string]: {
    arch?: string | string[];
    ubuntu?: string | string[];
    description?: string;
    postInstall?: string[];
  };
}

export interface SymlinkMapping {
  source: string;
  target: string;
  requiresSudo?: boolean;
  template?: string[];
}

export interface PostInstallTask {
  name: string;
  command: string;
  description?: string;
  template?: string[];
  requiresSudo?: boolean;
}

export enum ErrorType {
  CONFIGURATION_ERROR = "CONFIGURATION_ERROR",
  PLATFORM_ERROR = "PLATFORM_ERROR",
  PACKAGE_ERROR = "PACKAGE_ERROR",
  SYMLINK_ERROR = "SYMLINK_ERROR",
  PERMISSION_ERROR = "PERMISSION_ERROR",
}

export interface DotfilesError extends Error {
  type: ErrorType;
  recoverable: boolean;
  context?: Record<string, any>;
}

export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
  SUCCESS = "success",
}
