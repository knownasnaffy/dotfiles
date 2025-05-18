import signale from "signale";
import installArchPackages from "./arch";
import installUbuntuPackages from "./ubuntu";
import chalk from "chalk";

export default async function installPrograms(distro?: string) {
  const logger = signale.scope("Packages");

  if (!distro) {
    logger.error(
      "Couldn't determine you linux distro, skipping program installation.",
    );
  } else if (distro === "Arch Linux") {
    installArchPackages();
  } else if (distro.startsWith("Ubuntu")) {
    installUbuntuPackages();
  } else {
    logger.error(
      `Your distro is not explicitly supported. If you know it is a fork of either Arch or Ubuntu, use the ${chalk.blue("--arch")} or ${chalk.blue("--ubuntu")} flag to specify that.`,
    );
    logger.warn("Skipping package installation for now.");
  }
}
