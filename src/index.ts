import createDirs from "./directories";
import installPrograms from "./programs";
import { detectDistro } from "./utilities";
import determineTemplate from "./determine-template";
import signale from "signale";
import chalk from "chalk";

const hasInteractiveFlag = process.argv.includes("-i");

const hasUbuntuFlag = process.argv.includes("--ubuntu");
const hasArchFlag = process.argv.includes("--arch");

if (hasUbuntuFlag && hasArchFlag) {
  signale.error(
    `You can't specify both ${chalk.blue("--arch")} and ${chalk.blue("--ubuntu")} flags at the same time.`,
  );
  process.exit(1);
}

let distro: string | undefined = hasUbuntuFlag
  ? "Ubuntu"
  : hasArchFlag
    ? "Arch Linux"
    : await detectDistro();

const template = hasInteractiveFlag ? await determineTemplate() : "headless";
console.log(template);

//  TODO: Get passwordless access for sudo using something like
//        `${username} ALL=(ALL) NOPASSWD: /usr/bin/pacman\n`
//        by appending it to /etc/sudoers.d/temp-pacman-nopasswd
//
createDirs().catch(console.error);
installPrograms(distro).catch(console.error);
