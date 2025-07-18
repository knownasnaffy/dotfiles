import { describe, test, expect, beforeEach, mock } from "bun:test";
import { ConfigManagerImpl, ConfigurationError } from "../../../src/config/config-manager";
import { join } from "path";
import { mkdir, writeFile } from "fs/promises";

// Mock the file system operations
const mockReadFile = mock((path: string) => {
  if (path.includes("templates/valid.json")) {
    return JSON.stringify({
      name: "valid",
      description: "Valid template",
      packages: ["package1", "package2"],
      symlinks: ["symlink1", "symlink2"],
      postInstallTasks: ["task1", "task2"],
    });
  }

  if (path.includes("templates/invalid.json")) {
    return JSON.stringify({
      name: "invalid",
      description: "",
      packages: [],
    });
  }

  if (path.includes("packages.json")) {
    return JSON.stringify({
      package1: {
        arch: ["pkg1-arch"],
        ubuntu: ["pkg1-ubuntu"],
        description: "Package 1",
      },
      package2: {
        arch: "pkg2-arch",
        ubuntu: "pkg2-ubuntu",
        postInstall: ["post-install-cmd"],
      },
    });
  }

  if (path.includes("symlinks.json")) {
    return JSON.stringify([
      {
        source: ".config/app1",
        target: "~/.config/app1",
      },
      {
        source: "etc/app2",
        target: "/etc/app2",
        requiresSudo: true,
        template: ["desktop"],
      },
    ]);
  }

  if (path.includes("post-install.json")) {
    return JSON.stringify([
      {
        name: "task1",
        command: "command1",
        description: "Task 1",
      },
      {
        name: "task2",
        command: "command2",
        requiresSudo: true,
      },
    ]);
  }

  throw new Error(`File not found: ${path}`);
});

// Mock file access
const mockAccess = mock((path: string) => {
  if (
    path.includes("templates/valid.json") ||
    path.includes("packages.json") ||
    path.includes("symlinks.json") ||
    path.includes("post-install.json")
  ) {
    return Promise.resolve();
  }

  throw new Error(`File not found: ${path}`);
});

// Mock the fs module
mock.module("fs/promises", () => {
  return {
    readFile: mockReadFile,
    access: mockAccess,
    mkdir: mock(() => Promise.resolve()),
    writeFile: mock(() => Promise.resolve()),
  };
});

describe("ConfigManager", () => {
  let configManager: ConfigManagerImpl;
  const configPath = "/mock/config";

  beforeEach(() => {
    configManager = new ConfigManagerImpl(configPath);
    mockReadFile.mockClear();
    mockAccess.mockClear();
  });

  describe("loadTemplate", () => {
    test("should load a valid template", async () => {
      const template = await configManager.loadTemplate("valid");

      expect(template).toEqual({
        name: "valid",
        description: "Valid template",
        packages: ["package1", "package2"],
        symlinks: ["symlink1", "symlink2"],
        postInstallTasks: ["task1", "task2"],
      });

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });

    test("should throw for a non-existent template", async () => {
      await expect(configManager.loadTemplate("nonexistent")).rejects.toThrow(ConfigurationError);
      expect(mockAccess).toHaveBeenCalledTimes(1);
    });

    test("should cache templates", async () => {
      await configManager.loadTemplate("valid");
      await configManager.loadTemplate("valid");

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });
  });

  describe("loadPackageDefinitions", () => {
    test("should load package definitions", async () => {
      const packages = await configManager.loadPackageDefinitions();

      expect(packages).toEqual({
        package1: {
          arch: ["pkg1-arch"],
          ubuntu: ["pkg1-ubuntu"],
          description: "Package 1",
        },
        package2: {
          arch: "pkg2-arch",
          ubuntu: "pkg2-ubuntu",
          postInstall: ["post-install-cmd"],
        },
      });

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });

    test("should throw if packages.json is missing", async () => {
      mockAccess.mockImplementationOnce(() => Promise.reject(new Error("File not found")));

      await expect(configManager.loadPackageDefinitions()).rejects.toThrow(ConfigurationError);
      expect(mockAccess).toHaveBeenCalledTimes(1);
    });

    test("should cache package definitions", async () => {
      await configManager.loadPackageDefinitions();
      await configManager.loadPackageDefinitions();

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });
  });

  describe("loadSymlinkMappings", () => {
    test("should load symlink mappings", async () => {
      const symlinks = await configManager.loadSymlinkMappings();

      expect(symlinks).toEqual([
        {
          source: ".config/app1",
          target: "~/.config/app1",
        },
        {
          source: "etc/app2",
          target: "/etc/app2",
          requiresSudo: true,
          template: ["desktop"],
        },
      ]);

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });

    test("should throw if symlinks.json is missing", async () => {
      mockAccess.mockImplementationOnce(() => Promise.reject(new Error("File not found")));

      await expect(configManager.loadSymlinkMappings()).rejects.toThrow(ConfigurationError);
      expect(mockAccess).toHaveBeenCalledTimes(1);
    });

    test("should cache symlink mappings", async () => {
      await configManager.loadSymlinkMappings();
      await configManager.loadSymlinkMappings();

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });
  });

  describe("loadPostInstallTasks", () => {
    test("should load post-install tasks", async () => {
      const tasks = await configManager.loadPostInstallTasks();

      expect(tasks).toEqual([
        {
          name: "task1",
          command: "command1",
          description: "Task 1",
        },
        {
          name: "task2",
          command: "command2",
          requiresSudo: true,
        },
      ]);

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });

    test("should return empty array if post-install.json is missing", async () => {
      mockAccess.mockImplementationOnce(() => Promise.reject(new Error("File not found")));

      const tasks = await configManager.loadPostInstallTasks();
      expect(tasks).toEqual([]);
      expect(mockAccess).toHaveBeenCalledTimes(1);
    });

    test("should cache post-install tasks", async () => {
      await configManager.loadPostInstallTasks();
      await configManager.loadPostInstallTasks();

      expect(mockReadFile).toHaveBeenCalledTimes(1);
    });
  });

  describe("validateConfig", () => {
    test("should validate all configurations", async () => {
      // Mock the loadTemplate method to avoid file system access
      const loadTemplateSpy = mock((templateName: string) => {
        if (
          templateName === "headless" ||
          templateName === "desktop" ||
          templateName === "personal"
        ) {
          return Promise.resolve({
            name: templateName,
            description: "Valid template",
            packages: ["package1"],
            symlinks: ["symlink1"],
            postInstallTasks: ["task1"],
          });
        }
        throw new Error(`Template not found: ${templateName}`);
      });

      configManager.loadTemplate = loadTemplateSpy;

      const result = await configManager.validateConfig();
      expect(result).toBe(true);
      expect(loadTemplateSpy).toHaveBeenCalledTimes(3);
    });

    test("should throw if any configuration is invalid", async () => {
      // Mock the loadTemplate method to throw for one template
      const loadTemplateSpy = mock((templateName: string) => {
        if (templateName === "headless" || templateName === "desktop") {
          return Promise.resolve({
            name: templateName,
            description: "Valid template",
            packages: ["package1"],
            symlinks: ["symlink1"],
            postInstallTasks: ["task1"],
          });
        }
        throw new ConfigurationError(`Template not found: ${templateName}`);
      });

      configManager.loadTemplate = loadTemplateSpy;

      await expect(configManager.validateConfig()).rejects.toThrow(ConfigurationError);
      expect(loadTemplateSpy).toHaveBeenCalledTimes(3);
    });
  });

  describe("clearCache", () => {
    test("should clear all caches", async () => {
      await configManager.loadTemplate("valid");
      await configManager.loadPackageDefinitions();
      await configManager.loadSymlinkMappings();
      await configManager.loadPostInstallTasks();

      expect(mockReadFile).toHaveBeenCalledTimes(4);

      configManager.clearCache();

      await configManager.loadTemplate("valid");
      await configManager.loadPackageDefinitions();
      await configManager.loadSymlinkMappings();
      await configManager.loadPostInstallTasks();

      expect(mockReadFile).toHaveBeenCalledTimes(8);
    });
  });
});
