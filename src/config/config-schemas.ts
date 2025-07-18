import { z } from "zod";

/**
 * Schema for template configuration
 */
export const templateConfigSchema = z.object({
  name: z.string().min(1, "Template name is required"),
  description: z.string().min(1, "Template description is required"),
  packages: z.array(z.string()).min(1, "At least one package is required"),
  symlinks: z.array(z.string()),
  postInstallTasks: z.array(z.string()),
  requiresPrivatePackages: z.boolean().optional(),
});

/**
 * Schema for package definition
 */
const packageDefinitionSchema = z
  .object({
    arch: z.union([z.string(), z.array(z.string())]).optional(),
    ubuntu: z.union([z.string(), z.array(z.string())]).optional(),
    description: z.string().optional(),
    postInstall: z.array(z.string()).optional(),
  })
  .refine((data) => data.arch !== undefined || data.ubuntu !== undefined, {
    message: "Package must have at least one distribution definition (arch or ubuntu)",
    path: ["distribution"], // Add a path for the refinement error
  });

/**
 * Schema for package definitions
 */
export const packageDefinitionsSchema = z.record(z.string(), packageDefinitionSchema);

/**
 * Schema for symlink mapping
 */
export const symlinkMappingSchema = z.object({
  source: z.string().min(1, "Source path is required"),
  target: z.string().min(1, "Target path is required"),
  requiresSudo: z.boolean().optional(),
  template: z.array(z.string()).optional(),
});

/**
 * Schema for symlink mappings array
 */
export const symlinkMappingsSchema = z.array(symlinkMappingSchema);

/**
 * Schema for post-install task
 */
export const postInstallTaskSchema = z.object({
  name: z.string().min(1, "Task name is required"),
  command: z.string().min(1, "Command is required"),
  description: z.string().optional(),
  template: z.array(z.string()).optional(),
  requiresSudo: z.boolean().optional(),
});

/**
 * Schema for post-install tasks array
 */
export const postInstallTasksSchema = z.array(postInstallTaskSchema);

/**
 * Type for validation errors
 */
export type ValidationError = {
  path: string[];
  message: string;
};

/**
 * Validates a configuration object against its schema
 * @param schema Zod schema to validate against
 * @param data Data to validate
 * @param configName Name of the configuration for error reporting
 * @returns Array of validation errors, empty if valid
 */
export function validateConfig<T>(
  schema: z.ZodType<T>,
  data: unknown,
  configName: string
): ValidationError[] {
  try {
    schema.parse(data);
    return [];
  } catch (error) {
    if (error instanceof z.ZodError) {
      return error.issues.map((issue) => ({
        path: [configName, ...issue.path],
        message: issue.message,
      }));
    }
    return [
      {
        path: [configName],
        message: `Unknown validation error: ${String(error)}`,
      },
    ];
  }
}
