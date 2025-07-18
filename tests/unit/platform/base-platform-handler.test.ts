import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { BasePlatformHandler } from "../../../src/platform/base-platform-handler";
import { PlatformHandler } from "../../../src/platform/platform-handler.interface";
import { exec } from "child_process";

// Mock child_process.exec
vi.mock("child_process", () => ({
  exec: vi.fn(),
}));

// Create a concrete implementation of BasePlatformHandler for testing
class TestPlatformHandler extends BasePlatformHandler {
  name = "test-platform";

  async detect(): Promise<boolean> {
    return true;
  }

  getPackageManagerCommand(): string {
    return "test-pm";
  }

  async updateSystem(): Promise<void> {
    await this.executeCommand("test-pm update");
  }

  async setupPackageManager(): Promise<void> {
    await this.executeCommand("setup-test-pm");
  }

  async isPackageInstalled(packageName: string): Promise<boolean> {
    if (packageName === "installed-package") {
      return true;
    }
    return false;
  }

  protected getInstallCommand(packages: string[]): string {
    return `test-pm install ${packages.join(" ")}`;
  }
}

describe("BasePlatformHandler", () => {
  let handler: PlatformHandler;

  beforeEach(() => {
    handler = new TestPlatformHandler();
    vi.resetAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("installPackages", () => {
    it("should do nothing if packages array is empty", async () => {
      const spy = vi.spyOn(console, "log");

      await handler.installPackages([]);

      expect(exec).not.toHaveBeenCalled();
      spy.mockRestore();
    });

    it("should skip already installed packages", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "", stderr: "" });
        return {} as any;
      });

      await handler.installPackages(["installed-package"]);

      expect(exec).not.toHaveBeenCalled();
      expect(spy).toHaveBeenCalledWith("Package installed-package is already installed, skipping");
      spy.mockRestore();
    });

    it("should install packages that are not already installed", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "Package installed", stderr: "" });
        return {} as any;
      });

      await handler.installPackages(["new-package"]);

      expect(exec).toHaveBeenCalledWith("test-pm install new-package", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Successfully installed packages: new-package");
      spy.mockRestore();
    });

    it("should handle installation errors", async () => {
      const spy = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Installation failed"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      await expect(handler.installPackages(["new-package"])).rejects.toThrow();

      expect(exec).toHaveBeenCalledWith("test-pm install new-package", expect.any(Function));
      expect(spy).toHaveBeenCalledWith(
        "Failed to install packages: new-package",
        expect.any(Error)
      );
      spy.mockRestore();
    });
  });

  describe("executeCommand", () => {
    it("should execute commands and return results", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "Command output", stderr: "" });
        return {} as any;
      });

      const result = await (handler as any).executeCommand("test command");

      expect(exec).toHaveBeenCalledWith("test command", expect.any(Function));
      expect(result).toEqual({ stdout: "Command output", stderr: "" });
    });

    it("should handle command execution errors", async () => {
      const spy = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Command failed"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      await expect((handler as any).executeCommand("test command")).rejects.toThrow(
        "Command execution failed"
      );

      expect(exec).toHaveBeenCalledWith("test command", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Command execution failed: test command", expect.any(Error));
      spy.mockRestore();
    });
  });

  describe("commandExists", () => {
    it("should return true if command exists", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "/usr/bin/command", stderr: "" });
        return {} as any;
      });

      const result = await (handler as any).commandExists("existing-command");

      expect(exec).toHaveBeenCalledWith("command -v existing-command", expect.any(Function));
      expect(result).toBe(true);
    });

    it("should return false if command does not exist", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Command not found"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      const result = await (handler as any).commandExists("non-existing-command");

      expect(exec).toHaveBeenCalledWith("command -v non-existing-command", expect.any(Function));
      expect(result).toBe(false);
    });
  });
});
