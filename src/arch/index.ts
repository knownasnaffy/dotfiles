import { Signale } from "signale";
import installParu from "./paru";

export default async function installArchPackages() {
  const logger = new Signale({ interactive: true, scope: "Packages" });
  try {
    logger.await("Initializing Package installation");
    installParu();
  } catch (e) {}
}
