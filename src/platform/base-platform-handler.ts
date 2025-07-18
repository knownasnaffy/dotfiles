import { exec } from "child_process";
import { promisify } from "util";
import { PlatformHandler } from "./platform-handler.interface";

const execAsync = promisify(exec);

/**
 * Result of a command execution
 */
export interface CommandResult {
  stdout: string;
  stderr: string;
}

/**
 * Base abstract class for platform handlers
 * Provides common functionality for all platform handlers
 */
export abstract class BasePlatformHandler implements PlatformHandler {
  /**
   * Name of the platform/distribution
   */
  abstract name: string;

  /**
   * Detects if the current system matches this platform
   * @returns Promise resolving to true if platform is detected
   */
  abstract detect(): Promise<boolean>;

  /**
   * Gets the platform-specific package manager command
   * @returns The command used for package management
   */
  abstract getPackageManagerCommand(): string;

  /**
   * Updates the system package database
   */
  abstract updateSystem(): Promise<void>;

  /**
   * Sets up the package manager (e.g., installing paru on Arch)
   */
  abstract setupPackageManager(): Promise<void>;

  /**
   * Installs the specified packages using platform-specific methods
   * @param packages Array of package names to install
   */
  async installPackages(packages: string[]): Promise<void> {
    if (packages.length === 0) {
      return;
    }

    // Filter out already installed packages
    const packagesToInstall = [];
    for (const pkg of packages) {
      const isInstalled = await this.isPackageInstalled(pkg);
      if (!isInstalled) {
        packagesToInstall.push(pkg);
      } else {
        console.log(`Package ${pkg} is already installed, skipping`);
      }
    }

    if (packagesToInstall.length === 0) {
      console.log("All packages are already installed");
      return;
    }

    // Install the packages
    const installCommand = this.getInstallCommand(packagesToInstall);
    try {
      await this.executeCommand(installCommand);
      console.log(`Successfully installed packages: ${packagesToInstall.join(", ")}`);
    } catch (error) {
      console.error(`Failed to install packages: ${packagesToInstall.join(", ")}`, error);
      throw error;
    }
  }

  /**
   * Checks if a package is already installed
   * @param packageName Name of the package to check
   * @returns Promise resolving to true if package is installed
   */
  abstract isPackageInstalled(packageName: string): Promise<boolean>;

  /**
   * Gets the platform-specific install command for the given packages
   * @param packages Array of package names to install
   * @returns The command to install the packages
   */
  protected abstract getInstallCommand(packages: string[]): string;

  /**
   * Executes a shell command
   * @param command Command to execute
   * @returns Promise resolving to the command result
   */
  protected async executeCommand(command: string): Promise<CommandResult> {
    try {
      const { stdout, stderr } = await execAsync(command);
      return { stdout, stderr };
    } catch (error: any) {
      console.error(`Command execution failed: ${command}`, error);
      throw new Error(`Command execution failed: ${error.message}`);
    }
  }

  /**
   * Checks if a command exists in the system
   * @param command Command to check
   * @returns Promise resolving to true if command exists
   */
  protected async commandExists(command: string): Promise<boolean> {
    try {
      await execAsync(`command -v ${command}`);
      return true;
    } catch (error) {
      return false;
    }
  }
}
