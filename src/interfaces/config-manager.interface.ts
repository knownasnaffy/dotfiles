import {
  TemplateConfig,
  PackageDefinitions,
  SymlinkMapping,
  PostInstallTask,
} from "../types/index.js";

export interface ConfigManager {
  loadTemplate(templateName: string): Promise<TemplateConfig>;
  loadPackageDefinitions(): Promise<PackageDefinitions>;
  loadSymlinkMappings(): Promise<SymlinkMapping[]>;
  loadPostInstallTasks(): Promise<PostInstallTask[]>;
  validateConfig(): Promise<boolean>;
}
