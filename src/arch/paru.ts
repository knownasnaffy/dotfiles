import { $ } from "bun";
import { existsSync } from "fs";
import { commandExists } from "../utilities";
import signale from "signale";

export default async function installParu() {
  const logger = signale.scope("Packages");

  logger.await("Get sudo access");
  await $`sudo -v`;

  logger.await("Checking paru installation");
  const paruExists = await commandExists("paru");

  if (!paruExists) {
    logger.await("Paru not found, installing base packages");
    await $`sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel`.quiet();

    const clonePath = `${process.env.HOME}/code/clones/paru`;

    if (!existsSync(clonePath)) {
      logger.await("Cloning paru");
      await $`git clone https://aur.archlinux.org/paru.git ${clonePath}`.quiet();
    }

    logger.await("Building paru");
    await $`bash -c 'cd ${clonePath} && makepkg -si --noconfirm'`;
  } else {
    logger.success("Paru already installed");
  }
}
