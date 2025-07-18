import { SudoManager } from "../sudo/sudo-manager.interface";

/**
 * Interface for platform-specific package management handlers
 * Provides abstraction for different Linux distributions
 */
export interface PlatformHandler {
  /**
   * Name of the platform/distribution
   */
  name: string;

  /**
   * Detects if the current system matches this platform
   * @returns Promise resolving to true if platform is detected
   */
  detect(): Promise<boolean>;

  /**
   * Installs the specified packages using platform-specific methods
   * @param packages Array of package names to install
   */
  installPackages(packages: string[]): Promise<void>;

  /**
   * Sets up the package manager (e.g., installing paru on Arch)
   */
  setupPackageManager(): Promise<void>;

  /**
   * Gets the platform-specific package manager command
   * @returns The command used for package management
   */
  getPackageManagerCommand(): string;

  /**
   * Checks if a package is already installed
   * @param packageName Name of the package to check
   * @returns Promise resolving to true if package is installed
   */
  isPackageInstalled(packageName: string): Promise<boolean>;

  /**
   * Updates the system package database
   */
  updateSystem(): Promise<void>;

  /**
   * Sets the sudo manager for handling temporary permissions
   * @param sudoManager The sudo manager instance
   */
  setSudoManager(sudoManager: SudoManager): void;
}
