import { PlatformHandler } from "../platform/platform-handler.interface.js";
import { PackageDefinitions } from "../types/index.js";

/**
 * Interface for package management
 * Handles installation of packages across different platforms
 */
export interface PackageManager {
  /**
   * Installs all packages for a template
   * @param templateName Name of the template
   * @param platformHandler Platform-specific handler
   */
  installTemplate(
    templateName: string,
    platformHandler: PlatformHandler
  ): Promise<void>;

  /**
   * Installs a single package
   * @param packageName Name of the package
   * @param platformHandler Platform-specific handler
   */
  installPackage(
    packageName: string,
    platformHandler: PlatformHandler
  ): Promise<void>;

  /**
   * Checks if a package is already installed
   * @param packageName Name of the package
   * @param platformHandler Platform-specific handler
   * @returns True if package is installed
   */
  isPackageInstalled(
    packageName: string,
    platformHandler: PlatformHandler
  ): Promise<boolean>;

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
  ): string[];
}
