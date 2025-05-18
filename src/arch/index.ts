import signale from "signale";
import installParu from "./paru";

export default async function installArchPackages() {
  const logger = signale.scope("Packages");

  try {
    logger.await("Initializing Package installation");
    installParu();
  } catch (e) {}
}
