/**
 * Interface for the main orchestrator
 * Coordinates the entire installation process
 */
export interface Orchestrator {
  /**
   * Runs the complete installation process
   * @param templateName Name of the template to install
   * @param platformName Optional platform override
   */
  run(templateName: string, platformName?: string): Promise<void>;

  /**
   * Detects the platform and initializes the appropriate handler
   * @param platformOverride Optional platform override
   */
  detectPlatform(platformOverride?: string): Promise<void>;

  /**
   * Sets up the environment before installation
   */
  setupEnvironment(): Promise<void>;

  /**
   * Installs packages for the selected template
   * @param templateName Template name
   */
  installPackages(templateName: string): Promise<void>;

  /**
   * Creates symlinks for the selected template
   * @param templateName Template name
   */
  createSymlinks(templateName: string): Promise<void>;

  /**
   * Runs post-installation tasks
   * @param templateName Template name
   */
  runPostInstallTasks(templateName: string): Promise<void>;

  /**
   * Performs cleanup after installation
   */
  cleanup(): Promise<void>;
}
