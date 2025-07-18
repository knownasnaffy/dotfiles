import { PlatformHandler } from "./platform-handler.interface";
import { ArchHandler } from "./arch-handler";
import { UbuntuHandler } from "./ubuntu-handler";
import { LinuxDistribution, detectPlatform, parsePlatformArgs } from "./platform-detector";

/**
 * Creates a platform handler based on the detected or specified distribution
 * @param args Command-line arguments
 * @returns Promise resolving to the appropriate platform handler
 */
export async function createPlatformHandler(args: string[] = []): Promise<PlatformHandler> {
  try {
    // Parse command-line arguments for platform detection
    const options = parsePlatformArgs(args);

    // Detect the platform
    const distribution = await detectPlatform(options);

    // Create the appropriate platform handler
    switch (distribution) {
      case LinuxDistribution.ARCH:
        return new ArchHandler();
      case LinuxDistribution.UBUNTU:
        return new UbuntuHandler();
      default:
        throw new Error(`Unsupported distribution: ${distribution}`);
    }
  } catch (error) {
    console.error("Error creating platform handler:", error);
    throw error;
  }
}

export {
  PlatformHandler,
  ArchHandler,
  UbuntuHandler,
  LinuxDistribution,
  detectPlatform,
  parsePlatformArgs,
};
