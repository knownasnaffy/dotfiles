import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { ArchHandler } from "../../../src/platform/arch-handler";
import { exec } from "child_process";
import * as fs from "fs";

// Mock child_process.exec and fs.existsSync
vi.mock("child_process", () => ({
  exec: vi.fn(),
}));

vi.mock("fs", () => ({
  existsSync: vi.fn(),
}));

describe("ArchHandler", () => {
  let handler: ArchHandler;

  beforeEach(() => {
    handler = new ArchHandler();
    vi.resetAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("detect", () => {
    it("should detect Arch Linux", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(true);
      expect(exec).toHaveBeenCalledWith("cat /etc/os-release", expect.any(Function));
    });

    it("should detect Manjaro as Arch-based", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
NAME="Manjaro Linux"
ID=manjaro
ID_LIKE=arch
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(true);
    });

    it("should not detect Ubuntu as Arch", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
NAME="Ubuntu"
ID=ubuntu
ID_LIKE=debian
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(false);
    });

    it("should handle detection errors", async () => {
      const spy = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Command failed"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(false);
      expect(spy).toHaveBeenCalledWith("Error detecting Arch Linux:", expect.any(Error));
      spy.mockRestore();
    });
  });

  describe("getPackageManagerCommand", () => {
    it("should return paru", () => {
      const result = handler.getPackageManagerCommand();

      expect(result).toBe("paru");
    });
  });

  describe("updateSystem", () => {
    it("should update the package database", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "Database updated", stderr: "" });
        return {} as any;
      });

      await handler.updateSystem();

      expect(exec).toHaveBeenCalledWith("sudo pacman -Sy", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Updating Arch Linux package database...");
      expect(spy).toHaveBeenCalledWith("Package database updated successfully");
      spy.mockRestore();
    });

    it("should handle update errors", async () => {
      const spyLog = vi.spyOn(console, "log");
      const spyError = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Update failed"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      await expect(handler.updateSystem()).rejects.toThrow();

      expect(exec).toHaveBeenCalledWith("sudo pacman -Sy", expect.any(Function));
      expect(spyLog).toHaveBeenCalledWith("Updating Arch Linux package database...");
      expect(spyError).toHaveBeenCalledWith(
        "Failed to update package database:",
        expect.any(Error)
      );
      spyLog.mockRestore();
      spyError.mockRestore();
    });
  });

  describe("setupPackageManager", () => {
    it("should skip installation if paru is already installed", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v paru") {
          callback(null, { stdout: "/usr/bin/paru", stderr: "" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await handler.setupPackageManager();

      expect(exec).toHaveBeenCalledWith("command -v paru", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Paru is already installed");
      expect(exec).not.toHaveBeenCalledWith(
        expect.stringContaining("pacman -Sy"),
        expect.any(Function)
      );
      spy.mockRestore();
    });

    it("should install paru if not already installed", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v paru") {
          callback(new Error("Command not found"), { stdout: "", stderr: "Error" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      vi.mocked(fs.existsSync).mockReturnValue(false);

      // Mock process.env.HOME
      const originalHome = process.env.HOME;
      process.env.HOME = "/home/testuser";

      await handler.setupPackageManager();

      expect(exec).toHaveBeenCalledWith("command -v paru", expect.any(Function));
      expect(exec).toHaveBeenCalledWith(
        "sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel",
        expect.any(Function)
      );
      expect(exec).toHaveBeenCalledWith(
        "mkdir -p /home/testuser/code/clones",
        expect.any(Function)
      );
      expect(exec).toHaveBeenCalledWith(
        "git clone https://aur.archlinux.org/paru.git /home/testuser/code/clones/paru",
        expect.any(Function)
      );
      expect(exec).toHaveBeenCalledWith(
        "cd /home/testuser/code/clones/paru && makepkg -si --noconfirm",
        expect.any(Function)
      );

      expect(spy).toHaveBeenCalledWith("Installing paru AUR helper...");
      expect(spy).toHaveBeenCalledWith("Paru installed successfully");

      // Restore process.env.HOME
      process.env.HOME = originalHome;
      spy.mockRestore();
    });

    it("should handle setup errors", async () => {
      const spyLog = vi.spyOn(console, "log");
      const spyError = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v paru") {
          callback(new Error("Command not found"), { stdout: "", stderr: "Error" });
        } else if (cmd.includes("pacman -Sy")) {
          callback(new Error("Installation failed"), { stdout: "", stderr: "Error" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await expect(handler.setupPackageManager()).rejects.toThrow();

      expect(exec).toHaveBeenCalledWith("command -v paru", expect.any(Function));
      expect(spyLog).toHaveBeenCalledWith("Installing paru AUR helper...");
      expect(spyError).toHaveBeenCalledWith("Failed to setup package manager:", expect.any(Error));
      spyLog.mockRestore();
      spyError.mockRestore();
    });
  });

  describe("isPackageInstalled", () => {
    it("should return true if package is installed", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "zsh 5.9-1", stderr: "" });
        return {} as any;
      });

      const result = await handler.isPackageInstalled("zsh");

      expect(result).toBe(true);
      expect(exec).toHaveBeenCalledWith(
        'pacman -Q zsh 2>/dev/null || echo "not installed"',
        expect.any(Function)
      );
    });

    it("should return false if package is not installed", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "not installed", stderr: "" });
        return {} as any;
      });

      const result = await handler.isPackageInstalled("non-existent-package");

      expect(result).toBe(false);
    });

    it("should return false if command fails", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(new Error("Command failed"), { stdout: "", stderr: "Error" });
        return {} as any;
      });

      const result = await handler.isPackageInstalled("zsh");

      expect(result).toBe(false);
    });
  });

  describe("getInstallCommand", () => {
    it("should return the correct install command", () => {
      const result = (handler as any).getInstallCommand(["zsh", "git", "neovim"]);

      expect(result).toBe("paru -S --needed --noconfirm zsh git neovim");
    });
  });
});
