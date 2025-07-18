import { describe, test, expect } from "bun:test";
import {
  templateConfigSchema,
  packageDefinitionsSchema,
  symlinkMappingSchema,
  symlinkMappingsSchema,
  validateConfig,
} from "../../../src/config/config-schemas";

describe("Configuration Schemas", () => {
  describe("templateConfigSchema", () => {
    test("should validate a valid template config", () => {
      const validConfig = {
        name: "desktop",
        description: "Desktop environment setup",
        packages: ["base-tools", "desktop-environment"],
        symlinks: ["shell-configs", "desktop-configs"],
        postInstallTasks: ["setup-shell"],
        requiresPrivatePackages: false,
      };

      const result = validateConfig(templateConfigSchema, validConfig, "template");
      expect(result).toHaveLength(0);
    });

    test("should reject a template config with missing required fields", () => {
      const invalidConfig = {
        name: "desktop",
        description: "",
        packages: [],
      };

      const result = validateConfig(templateConfigSchema, invalidConfig, "template");
      expect(result.length).toBeGreaterThan(0);
      expect(result.some((err) => err.message.includes("description"))).toBe(true);
      expect(result.some((err) => err.message.includes("package"))).toBe(true);
    });
  });

  describe("packageDefinitionsSchema", () => {
    test("should validate valid package definitions", () => {
      const validPackages = {
        "base-tools": {
          arch: ["zsh", "git", "ripgrep"],
          ubuntu: ["zsh", "git", "ripgrep"],
          description: "Essential command-line tools",
        },
        "desktop-environment": {
          arch: "i3-wm",
          ubuntu: ["i3", "polybar"],
          postInstall: ["setup-i3"],
        },
      };

      // Parse directly to check if it's valid according to the schema
      const parsed = packageDefinitionsSchema.safeParse(validPackages);
      expect(parsed.success).toBe(true);
    });

    test("should reject package definitions without any distribution", () => {
      const invalidPackages = {
        "invalid-package": {
          description: "Missing distribution definitions",
        },
      };

      const parsed = packageDefinitionsSchema.safeParse(invalidPackages);
      expect(parsed.success).toBe(false);

      if (!parsed.success) {
        const errorMessage = parsed.error.issues[0].message;
        expect(errorMessage).toContain("distribution");
      }
    });
  });

  describe("symlinkMappingSchema", () => {
    test("should validate a valid symlink mapping", () => {
      const validMapping = {
        source: ".config/i3",
        target: "~/.config/i3",
        requiresSudo: false,
        template: ["desktop", "personal"],
      };

      const result = validateConfig(symlinkMappingSchema, validMapping, "symlink");
      expect(result).toHaveLength(0);
    });

    test("should reject a symlink mapping with missing required fields", () => {
      const invalidMapping = {
        source: "",
        target: "~/.config/i3",
      };

      const result = validateConfig(symlinkMappingSchema, invalidMapping, "symlink");
      expect(result.length).toBeGreaterThan(0);
      expect(result.some((err) => err.message.includes("Source"))).toBe(true);
    });
  });

  describe("symlinkMappingsSchema", () => {
    test("should validate an array of valid symlink mappings", () => {
      const validMappings = [
        {
          source: ".config/i3",
          target: "~/.config/i3",
        },
        {
          source: "etc/keyd",
          target: "/etc/keyd",
          requiresSudo: true,
        },
      ];

      const result = validateConfig(symlinkMappingsSchema, validMappings, "symlinks");
      expect(result).toHaveLength(0);
    });

    test("should reject an array with invalid symlink mappings", () => {
      const invalidMappings = [
        {
          source: ".config/i3",
          target: "~/.config/i3",
        },
        {
          source: "",
          target: "",
        },
      ];

      const result = validateConfig(symlinkMappingsSchema, invalidMappings, "symlinks");
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe("validateConfig", () => {
    test("should handle non-Zod errors", () => {
      // Mock a schema that throws a non-Zod error
      const mockSchema = {
        parse: () => {
          throw new Error("Non-Zod error");
        },
      };

      const result = validateConfig(mockSchema as any, {}, "test");
      expect(result).toHaveLength(1);
      expect(result[0].message).toContain("Unknown validation error");
    });
  });
});
