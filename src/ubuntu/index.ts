import { Signale } from "signale";

export default async function installUbuntuPackages() {
  const logger = new Signale({ interactive: true, scope: "Packages" });

  try {
    logger.await("Initializing Package installation");
    logger.complete("Initializing Package installation");
  } catch (e) {}
}
