import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { UbuntuHandler } from "../../../src/platform/ubuntu-handler";
import { exec } from "child_process";

// Mock child_process.exec
vi.mock("child_process", () => ({
  exec: vi.fn(),
}));

describe("UbuntuHandler", () => {
  let handler: UbuntuHandler;

  beforeEach(() => {
    handler = new UbuntuHandler();
    vi.resetAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("detect", () => {
    it("should detect Ubuntu", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
ID_LIKE=debian
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(true);
      expect(exec).toHaveBeenCalledWith("cat /etc/os-release", expect.any(Function));
    });

    it("should detect Debian", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(true);
    });

    it("should detect Debian-based distributions", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, {
          stdout: `
NAME="Linux Mint"
VERSION="21.2 (Victoria)"
ID=linuxmint
ID_LIKE=ubuntu debian
`,
          stderr: "",
        });
        return {} as any;
      });

      const result = await handler.detect();

      expect(result).toBe(true);
    });

    it("should not detect Arch as Ubuntu", async () => {
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
      expect(spy).toHaveBeenCalledWith("Error detecting Ubuntu/Debian:", expect.any(Error));
      spy.mockRestore();
    });
  });

  describe("getPackageManagerCommand", () => {
    it("should return apt", () => {
      const result = handler.getPackageManagerCommand();

      expect(result).toBe("apt");
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

      expect(exec).toHaveBeenCalledWith("sudo apt update", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Updating Ubuntu package database...");
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

      expect(exec).toHaveBeenCalledWith("sudo apt update", expect.any(Function));
      expect(spyLog).toHaveBeenCalledWith("Updating Ubuntu package database...");
      expect(spyError).toHaveBeenCalledWith(
        "Failed to update package database:",
        expect.any(Error)
      );
      spyLog.mockRestore();
      spyError.mockRestore();
    });
  });

  describe("setupPackageManager", () => {
    it("should set up the package manager", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "", stderr: "" });
        return {} as any;
      });

      await handler.setupPackageManager();

      expect(exec).toHaveBeenCalledWith("sudo apt update", expect.any(Function));
      expect(exec).toHaveBeenCalledWith(
        "sudo apt install -y software-properties-common apt-transport-https ca-certificates curl",
        expect.any(Function)
      );
      expect(spy).toHaveBeenCalledWith("Setting up package manager...");
      expect(spy).toHaveBeenCalledWith("Package manager setup complete");
      spy.mockRestore();
    });

    it("should handle setup errors", async () => {
      const spyLog = vi.spyOn(console, "log");
      const spyError = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "sudo apt update") {
          callback(new Error("Update failed"), { stdout: "", stderr: "Error" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await expect(handler.setupPackageManager()).rejects.toThrow();

      expect(exec).toHaveBeenCalledWith("sudo apt update", expect.any(Function));
      expect(spyLog).toHaveBeenCalledWith("Setting up package manager...");
      expect(spyError).toHaveBeenCalledWith("Failed to setup package manager:", expect.any(Error));
      spyLog.mockRestore();
      spyError.mockRestore();
    });
  });

  describe("isPackageInstalled", () => {
    it("should return true if package is installed", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "1", stderr: "" });
        return {} as any;
      });

      const result = await handler.isPackageInstalled("zsh");

      expect(result).toBe(true);
      expect(exec).toHaveBeenCalledWith(
        `dpkg-query -W -f='\${Status}' zsh 2>/dev/null | grep -c "ok installed" || echo "0"`,
        expect.any(Function)
      );
    });

    it("should return false if package is not installed", async () => {
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        callback(null, { stdout: "0", stderr: "" });
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

      expect(result).toBe("sudo apt install -y zsh git neovim");
    });
  });

  describe("installSnapPackage", () => {
    it("should install snap if not present", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v snap") {
          callback(new Error("Command not found"), { stdout: "", stderr: "Error" });
        } else if (cmd === 'snap list vscode 2>/dev/null || echo "not installed"') {
          callback(null, { stdout: "not installed", stderr: "" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await handler.installSnapPackage("vscode");

      expect(exec).toHaveBeenCalledWith("command -v snap", expect.any(Function));
      expect(exec).toHaveBeenCalledWith("sudo apt install -y snapd", expect.any(Function));
      expect(exec).toHaveBeenCalledWith(
        'snap list vscode 2>/dev/null || echo "not installed"',
        expect.any(Function)
      );
      expect(exec).toHaveBeenCalledWith("sudo snap install vscode", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Installing snap...");
      expect(spy).toHaveBeenCalledWith("Installing snap package vscode...");
      expect(spy).toHaveBeenCalledWith("Snap package vscode installed successfully");
      spy.mockRestore();
    });

    it("should skip installation if snap package is already installed", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v snap") {
          callback(null, { stdout: "/usr/bin/snap", stderr: "" });
        } else if (cmd === 'snap list vscode 2>/dev/null || echo "not installed"') {
          callback(null, {
            stdout: `Name    Version   Rev    Tracking       Publisher   Notes
vscode  1.85.1    252    latest/stable  microsoft    classic`,
            stderr: "",
          });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await handler.installSnapPackage("vscode");

      expect(exec).toHaveBeenCalledWith("command -v snap", expect.any(Function));
      expect(exec).toHaveBeenCalledWith(
        'snap list vscode 2>/dev/null || echo "not installed"',
        expect.any(Function)
      );
      expect(exec).not.toHaveBeenCalledWith("sudo snap install vscode", expect.any(Function));
      expect(spy).toHaveBeenCalledWith("Snap package vscode is already installed, skipping");
      spy.mockRestore();
    });

    it("should pass options to snap install command", async () => {
      const spy = vi.spyOn(console, "log");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v snap") {
          callback(null, { stdout: "/usr/bin/snap", stderr: "" });
        } else if (cmd === 'snap list vscode 2>/dev/null || echo "not installed"') {
          callback(null, { stdout: "not installed", stderr: "" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await handler.installSnapPackage("vscode", "--classic");

      expect(exec).toHaveBeenCalledWith("sudo snap install vscode --classic", expect.any(Function));
      spy.mockRestore();
    });

    it("should handle installation errors", async () => {
      const spyLog = vi.spyOn(console, "log");
      const spyError = vi.spyOn(console, "error");
      vi.mocked(exec).mockImplementation((cmd, callback: any) => {
        if (cmd === "command -v snap") {
          callback(null, { stdout: "/usr/bin/snap", stderr: "" });
        } else if (cmd === 'snap list vscode 2>/dev/null || echo "not installed"') {
          callback(null, { stdout: "not installed", stderr: "" });
        } else if (cmd === "sudo snap install vscode") {
          callback(new Error("Installation failed"), { stdout: "", stderr: "Error" });
        } else {
          callback(null, { stdout: "", stderr: "" });
        }
        return {} as any;
      });

      await expect(handler.installSnapPackage("vscode")).rejects.toThrow();

      expect(exec).toHaveBeenCalledWith("sudo snap install vscode", expect.any(Function));
      expect(spyLog).toHaveBeenCalledWith("Installing snap package vscode...");
      expect(spyError).toHaveBeenCalledWith(
        "Failed to install snap package vscode:",
        expect.any(Error)
      );
      spyLog.mockRestore();
      spyError.mockRestore();
    });
  });
});
