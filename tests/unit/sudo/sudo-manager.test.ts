import { describe, test, expect, beforeEach, afterEach, mock } from "bun:test";
import { SudoManagerImpl } from "../../../src/sudo/sudo-manager";
import * as fs from "fs/promises";
import * as os from "os";
import * as path from "path";

// Mock fs/promises
const mockWriteFile = mock(() => Promise.resolve());
const mockAccess = mock(() => Promise.resolve());

// Mock os.tmpdir
const mockTmpdir = mock(() => "/tmp");

// Setup mocks
mock.module("fs/promises", () => ({
  writeFile: mockWriteFile,
  access: mockAccess,
}));

mock.module("os", () => ({
  tmpdir: mockTmpdir,
}));

describe("SudoManager", () => {
  let sudoManager: SudoManagerImpl;

  beforeEach(() => {
    sudoManager = new SudoManagerImpl();

    // Mock the internal methods directly
    sudoManager.hasSudoAccess = mock(() => Promise.resolve(true));
    sudoManager.getCurrentUser = mock(() => Promise.resolve("testuser"));
    sudoManager.executeWithSudo = mock(() => Promise.resolve());

    // Reset mocks
    mockWriteFile.mockClear();
    mockAccess.mockClear();
  });

  afterEach(() => {
    mock.restore();
  });

  describe("setupTemporaryPermissions", () => {
    test("should create a temporary sudoers file with correct permissions", async () => {
      await sudoManager.setupTemporaryPermissions();

      // Check if file was written with correct content
      expect(mockWriteFile).toHaveBeenCalledTimes(1);
      expect(mockWriteFile.mock.calls[0][0]).toBe("/tmp/dotfiles-manager-temp");
      expect(mockWriteFile.mock.calls[0][1]).toContain("testuser ALL=(ALL) NOPASSWD:");

      // Check if permissions were set and file was moved
      expect(sudoManager.executeWithSudo).toHaveBeenCalledTimes(2);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe(
        "chmod 0440 /tmp/dotfiles-manager-temp"
      );
      expect(sudoManager.executeWithSudo.mock.calls[1][0]).toBe(
        "mv /tmp/dotfiles-manager-temp /etc/sudoers.d/dotfiles-manager-temp"
      );
    });

    test("should throw an error if sudo access is not available", async () => {
      // Override hasSudoAccess for this test only
      sudoManager.hasSudoAccess = mock(() => Promise.resolve(false));

      let error;
      try {
        await sudoManager.setupTemporaryPermissions();
      } catch (e) {
        error = e;
      }

      expect(error).toBeDefined();
      expect(error.message).toContain("Sudo access is required");
      expect(mockWriteFile).not.toHaveBeenCalled();
    });
  });

  describe("cleanupPermissions", () => {
    test("should remove the temporary sudoers file if it exists", async () => {
      mockAccess.mockImplementation(() => Promise.resolve());

      await sudoManager.cleanupPermissions();

      expect(sudoManager.executeWithSudo).toHaveBeenCalledTimes(1);
      expect(sudoManager.executeWithSudo.mock.calls[0][0]).toBe(
        "rm -f /etc/sudoers.d/dotfiles-manager-temp"
      );
    });

    test("should do nothing if the temporary sudoers file does not exist", async () => {
      mockAccess.mockImplementation(() => Promise.reject(new Error("File not found")));

      await sudoManager.cleanupPermissions();

      expect(sudoManager.executeWithSudo).not.toHaveBeenCalled();
    });
  });
});
