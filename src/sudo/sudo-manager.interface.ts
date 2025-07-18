/**
 * Interface for sudo permission management
 * Handles temporary sudo permissions for specific commands
 */
export interface SudoManager {
  /**
   * Sets up temporary sudo permissions
   * Creates temporary sudoers.d file
   */
  setupTemporaryPermissions(): Promise<void>;

  /**
   * Cleans up temporary sudo permissions
   * Removes temporary sudoers.d file
   */
  cleanupPermissions(): Promise<void>;

  /**
   * Executes a command with sudo privileges
   * @param command Command to execute
   */
  executeWithSudo(command: string): Promise<void>;

  /**
   * Checks if sudo access is available
   * @returns True if sudo access is available
   */
  hasSudoAccess(): Promise<boolean>;

  /**
   * Gets the current user name
   * @returns Current username
   */
  getCurrentUser(): Promise<string>;
}
