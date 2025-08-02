import { ConfigManager } from "../config/config-manager.interface.js";
import { Logger } from "../logger/logger.interface.js";
import { PlatformHandler } from "../platform/platform-handler.interface.js";
import { PackageDefinitions, ErrorType } from "../types/index.js";
import { PackageManager } from "./package-manager.interface.js";

/**
 * Error class for package management errors
 */
export class PackageError extends Error {
  type = ErrorType.PACKAGE_ERROR;
  recoverable: boolean;
  context?: Record<string, any>;

  constructor(message: string, recoverable = true, context?: Record<string, any>) {
    super(message);
    this.name = "PackageError";
    this.recoverable = recoverable;
    this.context = context ?? undefined;
  }
}

/**
 * Implementation of the PackageManager interface
 * Handles package installation across different platforms
 */
export class PackageManagerImpl implements PackageManager {
  private configManager: ConfigManager;
  private logger: Logger;

  /**
   * Creates a new PackageManager
   * @param configManager Configuration manager for loading package definitions
   * @param logger Logger for recording operations
   */
  constructor(configManager: ConfigManager, logger: Logger) {
    this.configManager = configManager;
    this.logger = logger;
  }

  /**
   * Installs all packages for a template
   * @param templateName Name of the template
   * @param platformHandler Platform-specific handler
   */
  async installTemplate(templateName: string, platformHandler: PlatformHandler): Promise<void> {
    try {
      this.logger.info(`Installing packages for template: ${templateName}`, { templateName });

      // Load template configuration
      const template = await this.configManager.loadTemplate(templateName);

      this.logger.info(`Found ${template.packages.length} package groups to install`, {
        templateName,
        packageCount: template.packages.length,
      });

      // Process each package in the template
      for (const packageName of template.packages) {
        try {
          await this.installPackage(packageName, platformHandler);
        } catch (error) {
          if (error instanceof PackageError && error.recoverable) {
            this.logger.warn(
              `Failed to install package ${packageName}, continuing with next package`,
              {
                packageName,
                error: error.message,
              }
            );
          } else {
            throw error;
          }
        }
      }

      this.logger.success(`Successfully installed packages for template: ${templateName}`, {
        templateName,
      });
    } catch (error) {
      this.logger.error(
        `Failed to install template packages: ${error instanceof Error ? error.message : String(error)}`
      );
      throw new PackageError(
        `Failed to install template packages: ${error instanceof Error ? error.message : String(error)}`,
        true,
        { templateName }
      );
    }
  }

  /**
   * Installs a single package
   * @param packageName Name of the package
   * @param platformHandler Platform-specific handler
   */
  async installPackage(packageName: string, platformHandler: PlatformHandler): Promise<void> {
    try {
      this.logger.info(`Processing package: ${packageName}`, { packageName });

      // Check if package is already installed
      const isInstalled = await this.isPackageInstalled(packageName, platformHandler);
      if (isInstalled) {
        this.logger.info(`Package ${packageName} is already installed, skipping`, { packageName });
        return;
      }

      // Load package definitions
      const packageDefinitions = await this.configManager.loadPackageDefinitions();

      // Get platform name
      const platformName = platformHandler.name;

      // Map package to platform-specific packages
      const platformPackages = this.mapPackageToPlatform(
        packageName,
        platformName,
        packageDefinitions
      );

      if (platformPackages.length === 0) {
        this.logger.warn(`No packages defined for ${packageName} on platform ${platformName}`, {
          packageName,
          platformName,
        });
        return;
      }

      this.logger.info(`Installing ${packageName} (${platformPackages.join(", ")})`, {
        packageName,
        platformPackages,
      });

      // Install the platform-specific packages
      await platformHandler.installPackages(platformPackages);

      // Verify installation was successful
      const verifyInstalled = await this.isPackageInstalled(packageName, platformHandler);
      if (!verifyInstalled) {
        throw new PackageError(`Package ${packageName} installation verification failed`, true, {
          packageName,
          platformPackages,
        });
      }

      this.logger.success(`Successfully installed package: ${packageName}`, { packageName });
    } catch (error) {
      this.logger.error(
        `Failed to install package ${packageName}: ${error instanceof Error ? error.message : String(error)}`
      );
      throw new PackageError(
        `Failed to install package ${packageName}: ${error instanceof Error ? error.message : String(error)}`,
        true,
        { packageName }
      );
    }
  }

  /**
   * Checks if a package is already installed
   * @param packageName Name of the package
   * @param platformHandler Platform-specific handler
   * @returns True if package is installed
   */
  async isPackageInstalled(
    packageName: string,
    platformHandler: PlatformHandler
  ): Promise<boolean> {
    try {
      // Load package definitions
      const packageDefinitions = await this.configManager.loadPackageDefinitions();

      // Get platform name
      const platformName = platformHandler.name;

      // Map package to platform-specific packages
      const platformPackages = this.mapPackageToPlatform(
        packageName,
        platformName,
        packageDefinitions
      );

      if (platformPackages.length === 0) {
        this.logger.warn(`No packages defined for ${packageName} on platform ${platformName}`, {
          packageName,
          platformName,
        });
        return false;
      }

      // Check if all platform-specific packages are installed
      for (const platformPackage of platformPackages) {
        const isInstalled = await platformHandler.isPackageInstalled(platformPackage);
        if (!isInstalled) {
          this.logger.debug(`Package ${platformPackage} is not installed`, { platformPackage });
          return false;
        }
      }

      this.logger.debug(`All packages for ${packageName} are installed`, { packageName });
      return true;
    } catch (error) {
      this.logger.error(
        `Failed to check if package ${packageName} is installed: ${error instanceof Error ? error.message : String(error)}`
      );
      return false;
    }
  }

  /**
   * Maps a package name to platform-specific package name(s)
   * @param packageName Generic package name
   * @param platformName Platform name (arch, ubuntu)
   * @param packageDefinitions All package definitions
   * @returns Platform-specific package name(s)
   */
  mapPackageToPlatform(
    packageName: string,
    platformName: string,
    packageDefinitions: PackageDefinitions
  ): string[] {
    // Check if package exists in definitions
    if (!(packageName in packageDefinitions)) {
      this.logger.warn(`Package ${packageName} not found in package definitions`, { packageName });
      return [];
    }

    // Get package definition
    const packageDef = packageDefinitions[packageName];
    if (!packageDef) {
      this.logger.warn(`Package ${packageName} not found in package definitions`, { packageName });
      return [];
    }

    // Get platform-specific package(s)
    const platformPackages = packageDef[platformName as keyof typeof packageDef];

    if (!platformPackages) {
      this.logger.warn(`No ${platformName} packages defined for ${packageName}`, {
        packageName,
        platformName,
      });
      return [];
    }

    // Convert to array if it's a string
    return Array.isArray(platformPackages) ? platformPackages : [platformPackages];
  }
}
