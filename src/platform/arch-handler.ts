import { existsSync } from "fs";
import { BasePlatformHandler } from "./base-platform-handler";
import { LinuxDistribution } from "./platform-detector";

/**
 * Arch Linux platform handler
 * Handles package management for Arch Linux and Arch-based distributions
 */
export class ArchHandler extends BasePlatformHandler {
  name = "arch";

  /**
   * Detects if the current system is Arch Linux
   * @returns Promise resolving to true if Arch Linux is detected
   */
  async detect(): Promise<boolean> {
    try {
      const { stdout } = await this.executeCommand("cat /etc/os-release");
      return (
        stdout.includes("ID=arch") ||
        stdout.includes("ID=manjaro") ||
        stdout.includes("ID=endeavouros")
      );
    } catch (error) {
      console.error("Error detecting Arch Linux:", error);
      return false;
    }
  }

  /**
   * Gets the package manager command (pacman or paru)
   * @returns The command used for package management
   */
  getPackageManagerCommand(): string {
    return "paru";
  }

  /**
   * Updates the system package database
   */
  async updateSystem(): Promise<void> {
    try {
      console.log("Updating Arch Linux package database...");
      await this.executeCommand("sudo pacman -Sy");
      console.log("Package database updated successfully");
    } catch (error) {
      console.error("Failed to update package database:", error);
      throw error;
    }
  }

  /**
   * Sets up the package manager (installs paru if not present)
   */
  async setupPackageManager(): Promise<void> {
    try {
      const paruExists = await this.commandExists("paru");

      if (paruExists) {
        console.log("Paru is already installed");
        return;
      }

      console.log("Installing paru AUR helper...");
      await this.installParu();
      console.log("Paru installed successfully");
    } catch (error) {
      console.error("Failed to setup package manager:", error);
      throw error;
    }
  }

  /**
   * Checks if a package is already installed
   * @param packageName Name of the package to check
   * @returns Promise resolving to true if package is installed
   */
  async isPackageInstalled(packageName: string): Promise<boolean> {
    try {
      const { stdout } = await this.executeCommand(
        `pacman -Q ${packageName} 2>/dev/null || echo "not installed"`
      );
      return !stdout.includes("not installed");
    } catch (error) {
      return false;
    }
  }

  /**
   * Gets the install command for the given packages
   * @param packages Array of package names to install
   * @returns The command to install the packages
   */
  protected getInstallCommand(packages: string[]): string {
    return `paru -S --needed --noconfirm ${packages.join(" ")}`;
  }

  /**
   * Installs the paru AUR helper
   */
  private async installParu(): Promise<void> {
    // Install base dependencies
    await this.executeCommand(
      "sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel"
    );

    // Clone paru repository
    const homeDir = process.env.HOME || "/home/user";
    const clonePath = `${homeDir}/code/clones/paru`;

    // Create directories if they don't exist
    await this.executeCommand(`mkdir -p ${homeDir}/code/clones`);

    if (!existsSync(clonePath)) {
      await this.executeCommand(`git clone https://aur.archlinux.org/paru.git ${clonePath}`);
    }

    // Build and install paru
    await this.executeCommand(`cd ${clonePath} && makepkg -si --noconfirm`);
  }
}
