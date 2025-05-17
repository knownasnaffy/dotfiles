import { $, sleep } from "bun";
import { existsSync } from "fs";
import { commandExists } from "../utilities";
import { Signale } from "signale";

export default async function installParu() {
  const logger = new Signale({ interactive: true, scope: "Packages" });
  logger.await("Checking paru installation");
  await sleep(2000);

  const paruExists = await commandExists("paru");

  if (!paruExists) {
    logger.await("Paru not found, installing base packages");
    await $`sudo pacman -Sy --noconfirm zsh make gcc ripgrep unzip git xclip neovim base-devel`;

    const clonePath = `${process.env.HOME}/code/clones/paru`;

    if (!existsSync(clonePath)) {
      await $`git clone https://aur.archlinux.org/paru.git ${clonePath}`;
    }

    await $`bash -c 'cd ${clonePath} && makepkg -si --noconfirm'`;
  } else {
    logger.success("Paru already installed");
  }
}
