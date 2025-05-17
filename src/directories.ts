import { mkdir } from "fs/promises";
import { existsSync } from "fs";
import { join } from "path";
import { Signale } from "signale";

// Example: Create multiple directories
const dirs = [".config", "code/clones", "code/projects", "code/other"];

export default async function createDirs(basePath = process.env.HOME || "~") {
  const logger = new Signale({
    interactive: true,
    scope: "Create Directories",
  });

  for (const dir of dirs) {
    const fullPath = join(basePath, dir);
    if (!existsSync(fullPath)) {
      await mkdir(fullPath, { recursive: true });
      logger.info(`Created: ${fullPath}`);
    } else {
      logger.info(`Already exists: ${fullPath}`);
    }
  }
}
