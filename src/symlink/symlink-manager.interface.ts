import { SymlinkMapping } from "../types/index.js";

/**
 * Interface for symlink management
 * Handles creating symlinks with intelligent backup
 */
export interface SymlinkManager {
  /**
   * Creates all symlinks from the provided mappings
   * @param mappings Array of symlink mappings to create
   * @param templateName Current template name for filtering
   */
  createSymlinks(
    mappings: SymlinkMapping[],
    templateName: string
  ): Promise<void>;

  /**
   * Creates a single symlink
   * @param source Source path (relative to dotfiles repo)
   * @param target Target path (absolute or home-relative)
   * @param requiresSudo Whether sudo is required for this symlink
   */
  createSymlink(
    source: string,
    target: string,
    requiresSudo?: boolean
  ): Promise<void>;

  /**
   * Backs up an existing file or directory
   * @param path Path to back up
   * @returns Path to the backup file
   */
  backupExisting(path: string): Promise<string>;

  /**
   * Checks if a symlink is already correctly set up
   * @param source Source path
   * @param target Target path
   * @returns True if symlink exists and points to correct source
   */
  isValidSymlink(source: string, target: string): Promise<boolean>;

  /**
   * Filters symlink mappings based on the current template
   * @param mappings All available symlink mappings
   * @param templateName Current template name
   * @returns Filtered symlink mappings for the template
   */
  filterMappingsByTemplate(
    mappings: SymlinkMapping[],
    templateName: string
  ): SymlinkMapping[];
}
