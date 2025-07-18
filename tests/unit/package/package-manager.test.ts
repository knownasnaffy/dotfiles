import { describe, it, expect, vi, beforeEach } from "vitest";
import { PackageManagerImpl } from "../../../src/package/package-manager";
import { ConfigManager } from "../../../src/config/config-manager.interface";
import { Logger } from "../../../src/logger/logger.interface";
import { PlatformHandler } from "../../../src/platform/platform-handler.interface";
import { PackageDefinitions, TemplateConfig } from "../../../src/types";

// Mock dependencies
const mockConfigManager = {
  loadTemplate: vi.fn(),
  loadPackageDefinitions: vi.fn(),
  loadSymlinkMappings: vi.fn(),
  loadPostInstallTasks: vi.fn(),
  validateConfig: vi.fn(),
  getConfigPath: vi.fn(),
} as unknown as ConfigManager;

const mockLogger = {
  info: vi.fn(),
  warn: vi.fn(),
  error: vi.fn(),
  success: vi.fn(),
  debug: vi.fn(),
  setLevel: vi.fn(),
  getLevel: vi.fn(),
} as unknown as Logger;

const mockPlatformHandler = {
  name: "arch",
  detect: vi.fn(),
  installPackages: vi.fn(),
  setupPackageManager: vi.fn(),
  getPackageManagerCommand: vi.fn(),
  isPackageInstalled: vi.fn(),
  updateSystem: vi.fn(),
  setSudoManager: vi.fn(),
} as unknown as PlatformHandler;

// Test data
const mockTemplateConfig: TemplateConfig = {
  name: "test-template",
  description: "Test template",
  packages: ["base-tools", "development"],
  symlinks: [],
  postInstallTasks: [],
};

const mockPackageDefinitions: PackageDefinitions = {
  "base-tools": {
    arch: ["git", "zsh", "curl"],
    ubuntu: ["git", "zsh", "curl"],
  },
  development: {
    arch: "nodejs",
    ubuntu: ["nodejs", "npm"],
  },
  "empty-package": {},
};

describe("PackageManagerImpl", () => {
  let packageManager: PackageManagerImpl;

  beforeEach(() => {
    // Reset mocks
    vi.resetAllMocks();

    // Setup default mock returns
    mockConfigManager.loadTemplate.mockResolvedValue(mockTemplateConfig);
    mockConfigManager.loadPackageDefinitions.mockResolvedValue(mockPackageDefinitions);
    mockPlatformHandler.isPackageInstalled.mockResolvedValue(false);

    // Create package manager instance
    packageManager = new PackageManagerImpl(mockConfigManager, mockLogger);
  });

  describe("installTemplate", () => {
    it("should install all packages for a template", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockResolvedValue();

      // Mock isPackageInstalled to return false first (check before install)
      // and then true after installation (verification check)
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValue(false).mockResolvedValueOnce(false).mockResolvedValueOnce(false);

      // Mock the second calls to return true (after installation)
      setTimeout(() => {
        spy.mockResolvedValue(true);
      }, 0);

      // Act
      await packageManager.installTemplate("test-template", mockPlatformHandler);

      // Assert
      expect(mockConfigManager.loadTemplate).toHaveBeenCalledWith("test-template");
      expect(mockConfigManager.loadPackageDefinitions).toHaveBeenCalled();
      expect(mockPlatformHandler.installPackages).toHaveBeenCalledTimes(2);
      expect(mockLogger.success).toHaveBeenCalledWith(
        expect.stringContaining("Successfully installed packages for template"),
        expect.any(Object)
      );
    });

    it("should continue with next package if one fails with recoverable error", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockImplementation((packages) => {
        if (packages.includes("git")) {
          throw new Error("Failed to install git");
        }
        return Promise.resolve();
      });

      // Mock isPackageInstalled
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockImplementation((pkg) => {
        return Promise.resolve(pkg === "development");
      });

      // Act
      await packageManager.installTemplate("test-template", mockPlatformHandler);

      // Assert
      expect(mockLogger.warn).toHaveBeenCalledWith(
        expect.stringContaining("Failed to install package"),
        expect.any(Object)
      );
      // We can't check for specific calls since the order is not guaranteed
      expect(mockPlatformHandler.installPackages).toHaveBeenCalled();
    });
  });

  describe("installPackage", () => {
    it("should install platform-specific packages", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockResolvedValue();

      // Mock isPackageInstalled
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValueOnce(false); // First check (not installed)
      spy.mockResolvedValueOnce(true); // Second check (installed)

      // Act
      await packageManager.installPackage("base-tools", mockPlatformHandler);

      // Assert
      expect(mockConfigManager.loadPackageDefinitions).toHaveBeenCalled();
      expect(mockPlatformHandler.installPackages).toHaveBeenCalledWith(["git", "zsh", "curl"]);
      expect(mockLogger.success).toHaveBeenCalledWith(
        expect.stringContaining("Successfully installed package"),
        expect.any(Object)
      );
    });

    it("should skip installation if package is already installed", async () => {
      // Arrange
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValueOnce(true); // Package is already installed

      // Act
      await packageManager.installPackage("base-tools", mockPlatformHandler);

      // Assert
      expect(mockPlatformHandler.installPackages).not.toHaveBeenCalled();
      expect(mockLogger.info).toHaveBeenCalledWith(
        expect.stringContaining("already installed, skipping"),
        expect.any(Object)
      );
    });

    it("should handle single string package definitions", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockResolvedValue();

      // Mock isPackageInstalled
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValueOnce(false); // First check (not installed)
      spy.mockResolvedValueOnce(true); // Second check (installed)

      // Act
      await packageManager.installPackage("development", mockPlatformHandler);

      // Assert
      expect(mockPlatformHandler.installPackages).toHaveBeenCalledWith(["nodejs"]);
    });

    it("should handle empty package definitions gracefully", async () => {
      // Arrange
      const spy = vi.spyOn(packageManager, "mapPackageToPlatform");
      spy.mockReturnValueOnce([]);

      // Act
      await packageManager.installPackage("empty-package", mockPlatformHandler);

      // Assert
      expect(mockPlatformHandler.installPackages).not.toHaveBeenCalled();
      expect(mockLogger.warn).toHaveBeenCalledWith(
        expect.stringContaining("No packages defined"),
        expect.any(Object)
      );
    });

    it("should verify installation was successful", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockResolvedValue();

      // Mock isPackageInstalled
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValueOnce(false); // First check (not installed)
      spy.mockResolvedValueOnce(true); // Second check (installed)

      // Act
      await packageManager.installPackage("base-tools", mockPlatformHandler);

      // Assert
      expect(mockPlatformHandler.installPackages).toHaveBeenCalledWith(["git", "zsh", "curl"]);
      expect(spy).toHaveBeenCalledTimes(2); // Once before, once after
    });

    it("should throw error if installation verification fails", async () => {
      // Arrange
      mockPlatformHandler.installPackages.mockResolvedValue();

      // Mock isPackageInstalled to always return false
      const spy = vi.spyOn(packageManager, "isPackageInstalled");
      spy.mockResolvedValue(false);

      // Act & Assert
      await expect(
        packageManager.installPackage("base-tools", mockPlatformHandler)
      ).rejects.toThrow("installation verification failed");

      expect(mockPlatformHandler.installPackages).toHaveBeenCalledWith(["git", "zsh", "curl"]);
      expect(mockLogger.error).toHaveBeenCalledWith(
        "Failed to install package base-tools: Package base-tools installation verification failed"
      );
    });
  });

  describe("isPackageInstalled", () => {
    it("should return true if all platform-specific packages are installed", async () => {
      // Arrange
      mockPlatformHandler.isPackageInstalled.mockResolvedValue(true);

      // Act
      const result = await packageManager.isPackageInstalled("base-tools", mockPlatformHandler);

      // Assert
      expect(result).toBe(true);
      expect(mockPlatformHandler.isPackageInstalled).toHaveBeenCalledTimes(3);
      expect(mockPlatformHandler.isPackageInstalled).toHaveBeenCalledWith("git");
      expect(mockPlatformHandler.isPackageInstalled).toHaveBeenCalledWith("zsh");
      expect(mockPlatformHandler.isPackageInstalled).toHaveBeenCalledWith("curl");
    });

    it("should return false if any platform-specific package is not installed", async () => {
      // Arrange
      mockPlatformHandler.isPackageInstalled.mockImplementation((pkg) => {
        return Promise.resolve(pkg !== "zsh");
      });

      // Act
      const result = await packageManager.isPackageInstalled("base-tools", mockPlatformHandler);

      // Assert
      expect(result).toBe(false);
    });

    it("should return false for undefined platform packages", async () => {
      // Arrange
      mockPlatformHandler.name = "unknown-platform";

      // Act
      const result = await packageManager.isPackageInstalled("base-tools", mockPlatformHandler);

      // Assert
      expect(result).toBe(false);
      expect(mockLogger.warn).toHaveBeenCalledWith(
        expect.stringContaining("No unknown-platform packages defined"),
        expect.any(Object)
      );
    });
  });

  describe("mapPackageToPlatform", () => {
    it("should map package name to platform-specific packages", () => {
      // Act
      const result = packageManager.mapPackageToPlatform(
        "base-tools",
        "arch",
        mockPackageDefinitions
      );

      // Assert
      expect(result).toEqual(["git", "zsh", "curl"]);
    });

    it("should convert single string to array", () => {
      // Act
      const result = packageManager.mapPackageToPlatform(
        "development",
        "arch",
        mockPackageDefinitions
      );

      // Assert
      expect(result).toEqual(["nodejs"]);
    });

    it("should return empty array for unknown package", () => {
      // Act
      const result = packageManager.mapPackageToPlatform(
        "unknown-package",
        "arch",
        mockPackageDefinitions
      );

      // Assert
      expect(result).toEqual([]);
      expect(mockLogger.warn).toHaveBeenCalledWith(
        expect.stringContaining("not found in package definitions"),
        expect.any(Object)
      );
    });

    it("should return empty array for unknown platform", () => {
      // Act
      const result = packageManager.mapPackageToPlatform(
        "base-tools",
        "unknown-platform",
        mockPackageDefinitions
      );

      // Assert
      expect(result).toEqual([]);
      expect(mockLogger.warn).toHaveBeenCalledWith(
        expect.stringContaining("No unknown-platform packages defined"),
        expect.any(Object)
      );
    });
  });
});
