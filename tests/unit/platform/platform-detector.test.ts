import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  detectLinuxDistribution,
  detectPlatform,
  parsePlatformArgs,
  LinuxDistribution,
} from "../../../src/platform/platform-detector";
import * as fs from "fs";
import * as fsPromises from "fs/promises";

// Mock fs and fs/promises modules
vi.mock("fs", async () => {
  const actual = await vi.importActual("fs");
  return {
    ...(actual as any),
    existsSync: vi.fn(),
  };
});

vi.mock("fs/promises", async () => {
  const actual = await vi.importActual("fs/promises");
  return {
    ...(actual as any),
    readFile: vi.fn(),
  };
});

describe("Platform Detection", () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("detectLinuxDistribution", () => {
    it("should return UNKNOWN if /etc/os-release does not exist", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(false);

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UNKNOWN);
      expect(fs.existsSync).toHaveBeenCalledWith("/etc/os-release");
    });

    it("should detect Arch Linux", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(
        `
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
LOGO=archlinux
` as any
      );

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.ARCH);
      expect(fs.existsSync).toHaveBeenCalledWith("/etc/os-release");
      expect(fsPromises.readFile).toHaveBeenCalledWith("/etc/os-release", "utf-8");
    });

    it("should detect Manjaro as Arch-based", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(
        `
NAME="Manjaro Linux"
ID=manjaro
ID_LIKE=arch
PRETTY_NAME="Manjaro Linux"
ANSI_COLOR="32;1;24;144;200"
HOME_URL="https://manjaro.org/"
SUPPORT_URL="https://manjaro.org/"
BUG_REPORT_URL="https://bugs.manjaro.org/"
` as any
      );

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.ARCH);
    });

    it("should detect Ubuntu", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(
        `
NAME="Ubuntu"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 22.04.3 LTS"
VERSION_ID="22.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=jammy
UBUNTU_CODENAME=jammy
` as any
      );

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UBUNTU);
    });

    it("should detect Debian as Ubuntu-like", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(
        `
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
` as any
      );

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UBUNTU);
    });

    it("should return UNKNOWN for unrecognized distributions", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(
        `
NAME="Fedora Linux"
VERSION="38 (Workstation Edition)"
ID=fedora
VERSION_ID=38
VERSION_CODENAME=""
PLATFORM_ID="platform:f38"
PRETTY_NAME="Fedora Linux 38 (Workstation Edition)"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=fedora-logo-icon
CPE_NAME="cpe:/o:fedoraproject:fedora:38"
HOME_URL="https://fedoraproject.org/"
DOCUMENTATION_URL="https://docs.fedoraproject.org/en-US/fedora/f38/system-administrators-guide/"
SUPPORT_URL="https://ask.fedoraproject.org/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_BUGZILLA_PRODUCT="Fedora"
REDHAT_BUGZILLA_PRODUCT_VERSION=38
REDHAT_SUPPORT_PRODUCT="Fedora"
REDHAT_SUPPORT_PRODUCT_VERSION=38
` as any
      );

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UNKNOWN);
    });

    it("should return UNKNOWN if os-release file is invalid", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue("Invalid content" as any);

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UNKNOWN);
    });

    it("should return UNKNOWN if reading os-release fails", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockRejectedValue(new Error("Failed to read file"));

      const result = await detectLinuxDistribution();

      expect(result).toBe(LinuxDistribution.UNKNOWN);
    });
  });

  describe("detectPlatform", () => {
    it("should use forced distribution if provided", async () => {
      const spy = vi.spyOn(global.console, "error").mockImplementation(() => {});

      const result = await detectPlatform({ forceDistribution: LinuxDistribution.UBUNTU });

      expect(result).toBe(LinuxDistribution.UBUNTU);
      expect(fs.existsSync).not.toHaveBeenCalled();
      expect(fsPromises.readFile).not.toHaveBeenCalled();

      spy.mockRestore();
    });

    it("should detect distribution if no forced distribution is provided", async () => {
      vi.mocked(fs.existsSync).mockReturnValue(true);
      vi.mocked(fsPromises.readFile).mockResolvedValue(`ID=arch` as any);

      const result = await detectPlatform();

      expect(result).toBe(LinuxDistribution.ARCH);
      expect(fs.existsSync).toHaveBeenCalledWith("/etc/os-release");
      expect(fsPromises.readFile).toHaveBeenCalledWith("/etc/os-release", "utf-8");
    });
  });

  describe("parsePlatformArgs", () => {
    it("should return empty options if no distribution flags are provided", () => {
      const result = parsePlatformArgs(["--other-flag"]);

      expect(result).toEqual({});
    });

    it("should set forceDistribution to ARCH if --arch flag is provided", () => {
      const result = parsePlatformArgs(["--arch", "--other-flag"]);

      expect(result).toEqual({ forceDistribution: LinuxDistribution.ARCH });
    });

    it("should set forceDistribution to UBUNTU if --ubuntu flag is provided", () => {
      const result = parsePlatformArgs(["--ubuntu", "--other-flag"]);

      expect(result).toEqual({ forceDistribution: LinuxDistribution.UBUNTU });
    });

    it("should throw an error if both --arch and --ubuntu flags are provided", () => {
      expect(() => parsePlatformArgs(["--arch", "--ubuntu"])).toThrow(
        "Conflicting distribution flags: --arch and --ubuntu cannot be used together"
      );
    });
  });
});
