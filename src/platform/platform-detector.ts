import { readFile } from "fs/promises";
import { existsSync } from "fs";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

/**
 * Supported Linux distributions
 */
export enum LinuxDistribution {
  ARCH = "arch",
  UBUNTU = "ubuntu",
  UNKNOWN = "unknown",
}

/**
 * Options for platform detection
 */
export interface PlatformDetectionOptions {
  /**
   * Force a specific distribution instead of auto-detection
   */
  forceDistribution?: LinuxDistribution;
}

/**
 * Detects the Linux distribution from /etc/os-release
 * @returns Promise resolving to the detected Linux distribution
 */
export async function detectLinuxDistribution(): Promise<LinuxDistribution> {
  // Check if /etc/os-release exists
  if (!existsSync("/etc/os-release")) {
    return LinuxDistribution.UNKNOWN;
  }

  try {
    // Read the os-release file
    const osReleaseContent = await readFile("/etc/os-release", "utf-8");

    // Parse the ID field
    const idMatch = osReleaseContent.match(/^ID=["']?([^"'\n]+)["']?$/m);
    if (!idMatch) {
      return LinuxDistribution.UNKNOWN;
    }

    const id = idMatch[1].toLowerCase();

    // Match the distribution
    if (id === "arch" || id === "manjaro" || id === "endeavouros") {
      return LinuxDistribution.ARCH;
    } else if (id === "ubuntu" || id === "debian") {
      return LinuxDistribution.UBUNTU;
    }

    return LinuxDistribution.UNKNOWN;
  } catch (error) {
    console.error("Error detecting Linux distribution:", error);
    return LinuxDistribution.UNKNOWN;
  }
}

/**
 * Detects the platform based on the provided options
 * @param options Platform detection options
 * @returns Promise resolving to the detected Linux distribution
 */
export async function detectPlatform(
  options?: PlatformDetectionOptions
): Promise<LinuxDistribution> {
  // If a distribution is forced, use that
  if (options?.forceDistribution) {
    return options.forceDistribution;
  }

  // Otherwise, detect the distribution
  return detectLinuxDistribution();
}

/**
 * Parses command-line arguments for platform detection
 * @param args Command-line arguments
 * @returns Platform detection options
 * @throws Error if conflicting distribution flags are provided
 */
export function parsePlatformArgs(args: string[]): PlatformDetectionOptions {
  const options: PlatformDetectionOptions = {};

  const hasArch = args.includes("--arch");
  const hasUbuntu = args.includes("--ubuntu");

  // Check for conflicting flags
  if (hasArch && hasUbuntu) {
    throw new Error("Conflicting distribution flags: --arch and --ubuntu cannot be used together");
  }

  // Set the forced distribution if specified
  if (hasArch) {
    options.forceDistribution = LinuxDistribution.ARCH;
  } else if (hasUbuntu) {
    options.forceDistribution = LinuxDistribution.UBUNTU;
  }

  return options;
}
