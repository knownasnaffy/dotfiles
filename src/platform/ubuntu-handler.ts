import { BasePlatformHandler } from "./base-platform-handler";

/**
 * Ubuntu platform handler
 * Handles package management for Ubuntu and Debian-based distributions
 */
export class UbuntuHandler extends BasePlatformHandler {
  name = "ubuntu";

  /**
   * Detects if the current system is Ubuntu or Debian-based
   * @returns Promise resolving to true if Ubuntu/Debian is detected
   */
  async detect(): Promise<boolean> {
    try {
      const { stdout } = await this.executeCommand("cat /etc/os-release");
      return (
        stdout.includes("ID=ubuntu") ||
        stdout.includes("ID=debian") ||
        stdout.includes("ID_LIKE=debian") ||
        stdout.includes('ID_LIKE="debian"') ||
        stdout.includes("ID_LIKE='debian'") ||
        stdout.includes("ID_LIKE=ubuntu") ||
        stdout.includes('ID_LIKE="ubuntu') ||
        stdout.includes("ID_LIKE='ubuntu")
      );
    } catch (error) {
      console.error("Error detecting Ubuntu/Debian:", error);
      return false;
    }
  }

  /**
   * Gets the package manager command (apt)
   * @returns The command used for package management
   */
  getPackageManagerCommand(): string {
    return "apt";
  }

  /**
   * Updates the system package database
   */
  async updateSystem(): Promise<void> {
    try {
      console.log("Updating Ubuntu package database...");
      await this.executeCommand("sudo apt update");
      console.log("Package database updated successfully");
    } catch (error) {
      console.error("Failed to update package database:", error);
      throw error;
    }
  }

  /**
   * Sets up the package manager
   * No additional setup needed for apt
   */
  async setupPackageManager(): Promise<void> {
    try {
      console.log("Setting up package manager...");
      // Ensure apt is up to date
      await this.updateSystem();

      // Install common dependencies
      await this.executeCommand(
        "sudo apt install -y software-properties-common apt-transport-https ca-certificates curl"
      );
      console.log("Package manager setup complete");
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
        `dpkg-query -W -f='\${Status}' ${packageName} 2>/dev/null | grep -c "ok installed" || echo "0"`
      );
      return stdout.trim() !== "0";
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
    return `sudo apt install -y ${packages.join(" ")}`;
  }

  /**
   * Installs a snap package
   * @param packageName Name of the snap package to install
   * @param options Additional snap options (e.g., --classic)
   */
  async installSnapPackage(packageName: string, options: string = ""): Promise<void> {
    try {
      // Check if snap is installed
      const snapExists = await this.commandExists("snap");
      if (!snapExists) {
        console.log("Installing snap...");
        await this.executeCommand("sudo apt install -y snapd");
      }

      // Check if the snap package is already installed
      const isInstalled = await this.isSnapPackageInstalled(packageName);
      if (isInstalled) {
        console.log(`Snap package ${packageName} is already installed, skipping`);
        return;
      }

      // Install the snap package
      console.log(`Installing snap package ${packageName}...`);
      await this.executeCommand(`sudo snap install ${packageName} ${options}`.trim());
      console.log(`Snap package ${packageName} installed successfully`);
    } catch (error) {
      console.error(`Failed to install snap package ${packageName}:`, error);
      throw error;
    }
  }

  /**
   * Checks if a snap package is already installed
   * @param packageName Name of the snap package to check
   * @returns Promise resolving to true if snap package is installed
   */
  private async isSnapPackageInstalled(packageName: string): Promise<boolean> {
    try {
      const { stdout } = await this.executeCommand(
        `snap list ${packageName} 2>/dev/null || echo "not installed"`
      );
      return !stdout.includes("not installed");
    } catch (error) {
      return false;
    }
  }
}
