import { $ } from "bun";
import { SudoManager } from "./sudo-manager.interface";
import * as fs from "fs/promises";
import * as path from "path";
import * as os from "os";

/**
 * Implementation of SudoManager for handling temporary sudo permissions
 * Creates and manages temporary sudoers.d files for specific commands
 */
export class SudoManagerImpl implements SudoManager {
  private readonly sudoersDir = "/etc/sudoers.d";
  private readonly tempSudoersFile = "dotfiles-manager-temp";
  private readonly fullSudoersPath: string;
  private readonly commands: string[] = [];

  constructor() {
    this.fullSudoersPath = path.join(this.sudoersDir, this.tempSudoersFile);

    // Default commands that need sudo permissions
    this.commands = [
      "/usr/bin/pacman",
      "/usr/bin/paru",
      "/usr/bin/ln",
      "/usr/bin/apt",
      "/usr/bin/apt-get",
      "/usr/bin/snap",
    ];
  }

  /**
   * Sets up temporary sudo permissions by creating a sudoers.d file
   * This allows specific commands to be run without password prompt
   */
  async setupTemporaryPermissions(): Promise<void> {
    try {
      const username = await this.getCurrentUser();

      // Create sudoers content that allows the current user to run specific commands without password
      const sudoersContent = this.commands
        .map((cmd) => `${username} ALL=(ALL) NOPASSWD: ${cmd}`)
        .join("\n");

      // Check if we have sudo access before proceeding
      const hasSudo = await this.hasSudoAccess();
      if (!hasSudo) {
        throw new Error("Sudo access is required to set up temporary permissions");
      }

      // Write the temporary sudoers file
      const tempFile = path.join(os.tmpdir(), this.tempSudoersFile);
      await fs.writeFile(tempFile, sudoersContent + "\n");

      // Move the file to sudoers.d with proper permissions
      await this.executeWithSudo(`chmod 0440 ${tempFile}`);
      await this.executeWithSudo(`mv ${tempFile} ${this.fullSudoersPath}`);

      console.log("Temporary sudo permissions set up successfully");
    } catch (error) {
      console.error("Failed to set up temporary sudo permissions:", error);
      throw error;
    }
  }

  /**
   * Cleans up temporary sudo permissions by removing the sudoers.d file
   */
  async cleanupPermissions(): Promise<void> {
    try {
      // Check if the temporary sudoers file exists
      try {
        await fs.access(this.fullSudoersPath);
      } catch {
        // File doesn't exist, nothing to clean up
        return;
      }

      // Remove the temporary sudoers file
      await this.executeWithSudo(`rm -f ${this.fullSudoersPath}`);
      console.log("Temporary sudo permissions cleaned up successfully");
    } catch (error) {
      console.error("Failed to clean up temporary sudo permissions:", error);
      throw error;
    }
  }

  /**
   * Executes a command with sudo privileges
   * @param command Command to execute
   */
  async executeWithSudo(command: string): Promise<void> {
    try {
      await $`sudo ${command}`.quiet();
    } catch (error) {
      console.error(`Failed to execute command with sudo: ${command}`, error);
      throw error;
    }
  }

  /**
   * Checks if sudo access is available
   * @returns True if sudo access is available
   */
  async hasSudoAccess(): Promise<boolean> {
    try {
      // Try to run a simple sudo command to check access
      await $`sudo -n true`.quiet();
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Gets the current user name
   * @returns Current username
   */
  async getCurrentUser(): Promise<string> {
    const result = await $`whoami`.quiet();
    return result.stdout.toString().trim();
  }
}
