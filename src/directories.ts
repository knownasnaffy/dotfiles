import { mkdir } from "fs/promises";
import { existsSync } from "fs";
import { join } from "path";
import signale from "signale";

const dirs = [".config", "code/clones", "code/projects", "code/sandbox"];

export default async function createDirs(basePath = process.env.HOME || "~") {
  const logger = signale.scope("Directories");

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
