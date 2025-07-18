import { describe, test, expect, beforeEach, afterEach, mock } from "bun:test";
import { BasePlatformHandler, CommandResult } from "../../../src/platform/base-platform-handler";
import { SudoManager } from "../../../src/sudo/sudo-manager.interface";
import { PlatformHandler } from "../../../src/platform/platform-handler.interface";

// Create a mock SudoManager for testing
class MockSudoManager implements SudoManager {
  setupTemporaryPermissions = mock(() => Promise.resolve());
  cleanupPermissions = mock(() => Promise.resolve());
  executeWithSudo = mock(() => Promise.resolve());
  hasSudoAccess = mock(() => Promise.resolve(true));
  getCurrentUser = mock(() => Promise.resolve("testuser"));
}

// Create a concrete implementation of BasePlatformHandler for testing
class TestPlatformHandler extends BasePlatformHandler {
  name = "test-platform";

  // Track calls to executeCommand for testing
  executeCommandCalls: { command: string; useSudo: boolean }[] = [];

  detect = mock(() => Promise.resolve(true));
  getPackageManagerCommand = mock(() => "test-pkg-mgr");
  updateSystem = mock(() => Promise.resolve());
  setupPackageManager = mock(() => Promise.resolve());
  isPackageInstalled = mock(() => Promise.resolve(false));

  protected getInstallCommand(packages: string[]): string {
    return `test-pkg-mgr install ${packages.join(" ")}`;
  }

  // Expose protected method for testing
  public async testExecuteCommand(
    command: string,
    useSudo: boolean = false
  ): Promise<CommandResult> {
    return this.executeCommand(command, useSudo);
  }

  // Override executeCommand for testing
  protected async executeCommand(
    command: string,
    useSudo: boolean = false
  ): Promise<CommandResult> {
    // Track the call
    this.executeCommandCalls.push({ command, useSudo });

    if (useSudo && this.sudoManager) {
      // If the command already starts with sudo, remove it to avoid double sudo
      const commandWithoutSudo = command.replace(/^sudo\s+/, "");
      await this.sudoManager.executeWithSudo(commandWithoutSudo);
      return { stdout: "", stderr: "" };
    } else {
      // Mock the exec behavior for testing
      return { stdout: "test output", stderr: "" };
    }
  }

  // Clear tracking data
  clearExecuteCommandCalls(): void {
    this.executeCommandCalls = [];
  }
}

describe("Platform Handler Sudo Integration", () => {
  let platformHandler: TestPlatformHandler;
  let sudoManager: MockSudoManager;

  beforeEach(() => {
    platformHandler = new TestPlatformHandler();
    sudoManager = new MockSudoManager();
    platformHandler.setSudoManager(sudoManager);
    platformHandler.clearExecuteCommandCalls();

    // Reset mocks
    sudoManager.setupTemporaryPermissions.mockClear();
    sudoManager.cleanupPermissions.mockClear();
    sudoManager.executeWithSudo.mockClear();
  });

  afterEach(() => {
    mock.restore();
  });

  describe("executeCommand", () => {
    test("should use SudoManager for sudo commands", async () => {
      await platformHandler.testExecuteCommand("test command", true);

      expect(sudoManager.executeWithSudo).toHaveBeenCalledTimes(1);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe("test command");
    });

    test("should remove sudo prefix when using SudoManager", async () => {
      await platformHandler.testExecuteCommand("sudo test command", true);

      expect(sudoManager.executeWithSudo).toHaveBeenCalledTimes(1);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe("test command");
    });

    test("should not use SudoManager when useSudo is false", async () => {
      await platformHandler.testExecuteCommand("test command", false);
      expect(sudoManager.executeWithSudo).not.toHaveBeenCalled();
    });
  });

  describe("installPackages", () => {
    test("should set up temporary permissions before installing packages", async () => {
      await platformHandler.installPackages(["package1", "package2"]);

      expect(sudoManager.setupTemporaryPermissions).toHaveBeenCalledTimes(1);
      expect(platformHandler.executeCommandCalls.length).toBe(1);
      expect(platformHandler.executeCommandCalls[0].command).toBe(
        "test-pkg-mgr install package1 package2"
      );
      expect(platformHandler.executeCommandCalls[0].useSudo).toBe(true);
    });

    test("should clean up permissions even if installation fails", async () => {
      // Override executeCommand to throw an error
      platformHandler.testExecuteCommand = async () => {
        throw new Error("Installation failed");
      };

      try {
        await platformHandler.installPackages(["package1"]);
      } catch (error) {
        // Expected to throw
      }

      expect(sudoManager.setupTemporaryPermissions).toHaveBeenCalledTimes(1);
      expect(sudoManager.cleanupPermissions).toHaveBeenCalledTimes(1);
    });

    test("should continue if setting up temporary permissions fails", async () => {
      // Mock setupTemporaryPermissions to throw an error
      sudoManager.setupTemporaryPermissions.mockImplementation(() => {
        throw new Error("Failed to set up permissions");
      });

      await platformHandler.installPackages(["package1"]);

      expect(sudoManager.setupTemporaryPermissions).toHaveBeenCalledTimes(1);
      expect(platformHandler.executeCommandCalls.length).toBe(1);
      expect(sudoManager.cleanupPermissions).toHaveBeenCalledTimes(1);
    });

    test("should skip already installed packages", async () => {
      // Mock isPackageInstalled to return true
      platformHandler.isPackageInstalled = mock(() => Promise.resolve(true));

      await platformHandler.installPackages(["package1", "package2"]);

      expect(sudoManager.setupTemporaryPermissions).not.toHaveBeenCalled();
      expect(platformHandler.executeCommandCalls.length).toBe(0);
      expect(sudoManager.cleanupPermissions).not.toHaveBeenCalled();
    });
  });
});
