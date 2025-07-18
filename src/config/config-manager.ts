import { join } from "path";
import { readFile, access } from "fs/promises";
import { constants } from "fs";
import { z } from "zod";
import {
  templateConfigSchema,
  packageDefinitionsSchema,
  symlinkMappingsSchema,
  postInstallTasksSchema,
  validateConfig,
  ValidationError,
} from "./config-schemas.js";
import {
  TemplateConfig,
  PackageDefinitions,
  SymlinkMapping,
  PostInstallTask,
  ErrorType,
} from "../types/index.js";

/**
 * Error class for configuration errors
 */
export class ConfigurationError extends Error {
  type = ErrorType.CONFIGURATION_ERROR;
  recoverable: boolean;
  context?: Record<string, any>;

  constructor(message: string, recoverable = false, context?: Record<string, any>) {
    super(message);
    this.name = "ConfigurationError";
    this.recoverable = recoverable;
    this.context = context;
  }
}

/**
 * Implementation of the ConfigManager interface
 */
export class ConfigManagerImpl {
  private configPath: string;
  private templateCache: Map<string, TemplateConfig> = new Map();
  private packageDefinitionsCache: PackageDefinitions | null = null;
  private symlinkMappingsCache: SymlinkMapping[] | null = null;
  private postInstallTasksCache: PostInstallTask[] | null = null;

  /**
   * Creates a new ConfigManager
   * @param configPath Path to the configuration directory
   */
  constructor(configPath: string) {
    this.configPath = configPath;
  }

  /**
   * Gets the path to configuration files
   * @returns The directory path containing configuration files
   */
  getConfigPath(): string {
    return this.configPath;
  }

  /**
   * Loads a template configuration by name
   * @param templateName Name of the template to load
   * @returns Promise resolving to the template configuration
   * @throws ConfigurationError if the template doesn't exist or is invalid
   */
  async loadTemplate(templateName: string): Promise<TemplateConfig> {
    // Check cache first
    if (this.templateCache.has(templateName)) {
      return this.templateCache.get(templateName)!;
    }

    const templatePath = join(this.configPath, "templates", `${templateName}.json`);

    try {
      // Check if file exists
      await access(templatePath, constants.R_OK);
    } catch (error) {
      throw new ConfigurationError(
        `Template '${templateName}' not found at ${templatePath}`,
        false,
        { templateName, templatePath }
      );
    }

    try {
      const templateContent = await readFile(templatePath, "utf-8");
      const templateData = JSON.parse(templateContent);

      // Validate template
      const validationErrors = validateConfig(templateConfigSchema, templateData, "template");
      if (validationErrors.length > 0) {
        throw new ConfigurationError(
          `Invalid template configuration: ${validationErrors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`,
          false,
          { templateName, errors: validationErrors }
        );
      }

      const template = templateData as TemplateConfig;
      this.templateCache.set(templateName, template);
      return template;
    } catch (error) {
      if (error instanceof ConfigurationError) {
        throw error;
      }
      if (error instanceof SyntaxError) {
        throw new ConfigurationError(
          `Invalid JSON in template configuration: ${error.message}`,
          false,
          { templateName, templatePath }
        );
      }
      throw new ConfigurationError(
        `Failed to load template '${templateName}': ${String(error)}`,
        false,
        { templateName, error }
      );
    }
  }

  /**
   * Loads all package definitions
   * @returns Promise resolving to package definitions
   * @throws ConfigurationError if the package definitions are invalid
   */
  async loadPackageDefinitions(): Promise<PackageDefinitions> {
    // Check cache first
    if (this.packageDefinitionsCache) {
      return this.packageDefinitionsCache;
    }

    const packagesPath = join(this.configPath, "packages.json");

    try {
      // Check if file exists
      await access(packagesPath, constants.R_OK);
    } catch (error) {
      throw new ConfigurationError(`Package definitions not found at ${packagesPath}`, false, {
        packagesPath,
      });
    }

    try {
      const packagesContent = await readFile(packagesPath, "utf-8");
      const packagesData = JSON.parse(packagesContent);

      // Validate packages
      const validationErrors = validateConfig(packageDefinitionsSchema, packagesData, "packages");
      if (validationErrors.length > 0) {
        throw new ConfigurationError(
          `Invalid package definitions: ${validationErrors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`,
          false,
          { errors: validationErrors }
        );
      }

      const packages = packagesData as PackageDefinitions;
      this.packageDefinitionsCache = packages;
      return packages;
    } catch (error) {
      if (error instanceof ConfigurationError) {
        throw error;
      }
      if (error instanceof SyntaxError) {
        throw new ConfigurationError(
          `Invalid JSON in package definitions: ${error.message}`,
          false,
          { packagesPath }
        );
      }
      throw new ConfigurationError(`Failed to load package definitions: ${String(error)}`, false, {
        error,
      });
    }
  }

  /**
   * Loads all symlink mappings
   * @returns Promise resolving to an array of symlink mappings
   * @throws ConfigurationError if the symlink mappings are invalid
   */
  async loadSymlinkMappings(): Promise<SymlinkMapping[]> {
    // Check cache first
    if (this.symlinkMappingsCache) {
      return this.symlinkMappingsCache;
    }

    const symlinksPath = join(this.configPath, "symlinks.json");

    try {
      // Check if file exists
      await access(symlinksPath, constants.R_OK);
    } catch (error) {
      throw new ConfigurationError(`Symlink mappings not found at ${symlinksPath}`, false, {
        symlinksPath,
      });
    }

    try {
      const symlinksContent = await readFile(symlinksPath, "utf-8");
      const symlinksData = JSON.parse(symlinksContent);

      // Validate symlinks
      const validationErrors = validateConfig(symlinkMappingsSchema, symlinksData, "symlinks");
      if (validationErrors.length > 0) {
        throw new ConfigurationError(
          `Invalid symlink mappings: ${validationErrors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`,
          false,
          { errors: validationErrors }
        );
      }

      const symlinks = symlinksData as SymlinkMapping[];
      this.symlinkMappingsCache = symlinks;
      return symlinks;
    } catch (error) {
      if (error instanceof ConfigurationError) {
        throw error;
      }
      if (error instanceof SyntaxError) {
        throw new ConfigurationError(`Invalid JSON in symlink mappings: ${error.message}`, false, {
          symlinksPath,
        });
      }
      throw new ConfigurationError(`Failed to load symlink mappings: ${String(error)}`, false, {
        error,
      });
    }
  }

  /**
   * Loads all post-installation tasks
   * @returns Promise resolving to an array of post-install tasks
   * @throws ConfigurationError if the post-install tasks are invalid
   */
  async loadPostInstallTasks(): Promise<PostInstallTask[]> {
    // Check cache first
    if (this.postInstallTasksCache) {
      return this.postInstallTasksCache;
    }

    const tasksPath = join(this.configPath, "post-install.json");

    try {
      // Check if file exists
      await access(tasksPath, constants.R_OK);
    } catch (error) {
      // Post-install tasks are optional, return empty array if not found
      return [];
    }

    try {
      const tasksContent = await readFile(tasksPath, "utf-8");
      const tasksData = JSON.parse(tasksContent);

      // Validate tasks
      const validationErrors = validateConfig(postInstallTasksSchema, tasksData, "tasks");
      if (validationErrors.length > 0) {
        throw new ConfigurationError(
          `Invalid post-install tasks: ${validationErrors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`,
          false,
          { errors: validationErrors }
        );
      }

      const tasks = tasksData as PostInstallTask[];
      this.postInstallTasksCache = tasks;
      return tasks;
    } catch (error) {
      if (error instanceof ConfigurationError) {
        throw error;
      }
      if (error instanceof SyntaxError) {
        throw new ConfigurationError(
          `Invalid JSON in post-install tasks: ${error.message}`,
          false,
          { tasksPath }
        );
      }
      throw new ConfigurationError(`Failed to load post-install tasks: ${String(error)}`, false, {
        error,
      });
    }
  }

  /**
   * Validates all configuration files
   * @returns Promise resolving to true if all configs are valid
   * @throws ConfigurationError if any configuration is invalid
   */
  async validateConfig(): Promise<boolean> {
    const errors: ValidationError[] = [];

    // Validate templates
    try {
      const templatesDir = join(this.configPath, "templates");
      // This would need to be implemented to list files in the templates directory
      // For now, we'll just validate the standard templates
      const templateNames = ["headless", "desktop", "personal"];

      for (const templateName of templateNames) {
        try {
          await this.loadTemplate(templateName);
        } catch (error) {
          if (error instanceof ConfigurationError) {
            errors.push({
              path: ["templates", templateName],
              message: error.message,
            });
          } else {
            errors.push({
              path: ["templates", templateName],
              message: `Unknown error: ${String(error)}`,
            });
          }
        }
      }
    } catch (error) {
      errors.push({
        path: ["templates"],
        message: `Failed to validate templates: ${String(error)}`,
      });
    }

    // Validate packages
    try {
      await this.loadPackageDefinitions();
    } catch (error) {
      if (error instanceof ConfigurationError) {
        errors.push({
          path: ["packages"],
          message: error.message,
        });
      } else {
        errors.push({
          path: ["packages"],
          message: `Unknown error: ${String(error)}`,
        });
      }
    }

    // Validate symlinks
    try {
      await this.loadSymlinkMappings();
    } catch (error) {
      if (error instanceof ConfigurationError) {
        errors.push({
          path: ["symlinks"],
          message: error.message,
        });
      } else {
        errors.push({
          path: ["symlinks"],
          message: `Unknown error: ${String(error)}`,
        });
      }
    }

    // Validate post-install tasks
    try {
      await this.loadPostInstallTasks();
    } catch (error) {
      if (error instanceof ConfigurationError) {
        errors.push({
          path: ["post-install"],
          message: error.message,
        });
      } else {
        errors.push({
          path: ["post-install"],
          message: `Unknown error: ${String(error)}`,
        });
      }
    }

    if (errors.length > 0) {
      throw new ConfigurationError(
        `Configuration validation failed: ${errors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`,
        false,
        { errors }
      );
    }

    return true;
  }

  /**
   * Clears all caches
   */
  clearCache(): void {
    this.templateCache.clear();
    this.packageDefinitionsCache = null;
    this.symlinkMappingsCache = null;
    this.postInstallTasksCache = null;
  }
}
