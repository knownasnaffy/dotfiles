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

  // Track calls to executeCommand for testin
  executeCommandCalls: { command: string, useSudo: boole

  detect = mock(() => Promise.resolve(true));
  getPackageManagerCommand = mock(() => "test-pkg-mgr");

  setupPackageManager = mock(() => Promise.resolve());
  isPackageInstalled = mock(() => Promise.resolve(false)

{
    return `test-pkg-mgr install ${packa ")}`;
  }

  // Expose protected methodsting
  public async testExecuteCom
    command: string,
   an = false

    return this.executeCommand(command, 
  }
  
  // Override executeCommandtesting
  protected async executeComm
    command: string,
    useSudo: boolean = false
  ): Promise<CommandResult> {
    // Track the call
    this.executeCommandCalls.push({ commdo });
    
    if (useSudo && this.sudoManager) {
      // If the command already starts with sudo, rouble sudo
     
   utSudo);
 ;
se {
      // Mock the exec behavior for testing
      return { stdout: 'test output', stder;
    }

  
  // Clear tracking data
  clearExecuteCommandCalls(): void {
    this.executeCommandCalls = [];
  }
}

describe("Platform Handler Sudo Integration", () => {
  let platformHandler: TestPlatformHandler;
  letr;

  beforeEach(() => {
    platformHandler();
    s
er);
    platformHandler.clearExecuteCommalls();

    // Reset mocks
Clear();
    sudoManager.cleanupPermissions.mockClear();
    sudoManager.executeWithSudo.mockClear();
  });

  afterEach(() => {
    mock.restore();


  describe("executeCommand", () => {
    tes> {
;

      expect(sudoManager.executeWithSudo).toHaveBeenCalledTimes(1);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe("");
    });


      await platformHandler.testExecue);

      expect(sudoManager.executeWithSudo).toHaveBees(1);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe("test comman");
    });

> {
      await platformHandler.testExecuteCommand("test command", false);
      expect(sudoManager.executeWithSudo).not.toHaveBeenC
    });
  });


    test("should set up temporary permissions before installing packages", async() => {
      await platformHandler.installPackages(["package1", "package2"]);

      expect(sudoManager.setupTemporaryPermissi);
      exp1);
e2");
      expec
    });

    test("should clean up pe
      /error
{
        throw new Error("Installation failed");
      };

{
        await platformHandler.installPackages(["package1"]);
      } catch (error) {
        // Expected to throw
      }

es(1);
      expect(sudoManager.cleanupPermissions).toHav);
    });

    test("should continue if setting up temporary permissi () => {
 error
      sudoManager.setupTemporaryPermissions.mockImplementation(() => {
        throw new Error("Failed to set up permissions");
      });



      expect(sudoManager.setupTemporaryPermissis(1);
      expect(platformHandler.executeCommandCalls.length).toBe(1);
;
    });

) => {
      // Mock isPackageInstalled to return true


      await platformHandler.installPackages(["package1""]);

      e);
     
   
;
});})    });
  