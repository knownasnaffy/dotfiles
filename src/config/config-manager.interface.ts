import {
  TemplateConfig,
  PackageDefinitions,
  SymlinkMapping,
  PostInstallTask,
} from "../types/index.js";

/**
 * Interface for configuration management
 * Handles loading and validating configuration files
 */
export interface ConfigManager {
  /**
   * Loads a template configuration by name
   * @param templateName Name of the template to load
   * @returns Promise resolving to the template configuration
   */
  loadTemplate(templateName: string): Promise<TemplateConfig>;

  /**
   * Loads all package definitions
   * @returns Promise resolving to package definitions
   */
  loadPackageDefinitions(): Promise<PackageDefinitions>;

  /**
   * Loads all symlink mappings
   * @returns Promise resolving to an array of symlink mappings
   */
  loadSymlinkMappings(): Promise<SymlinkMapping[]>;

  /**
   * Loads all post-installation tasks
   * @returns Promise resolving to an array of post-install tasks
   */
  loadPostInstallTasks(): Promise<PostInstallTask[]>;

  /**
   * Validates all configuration files
   * @returns Promise resolving to true if all configs are valid
   */
  validateConfig(): Promise<boolean>;

  /**
   * Gets the path to configuration files
   * @returns The directory path containing configuration files
   */
  getConfigPath(): string;
}
