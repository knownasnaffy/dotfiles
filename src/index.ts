import createDirs from "./directories";
import installPrograms from "./programs";
import { detectDistro } from "./utilities";
import determineTemplate from "./determine-template";

const hasInteractiveFlag = process.argv.includes("-i");

const distro: string | undefined = await detectDistro();

const template = hasInteractiveFlag ? await determineTemplate() : "headless";
console.log(template);

//  TODO: Get passwordless access for sudo using something like
//        `${username} ALL=(ALL) NOPASSWD: /usr/bin/pacman\n`
//        by appending it to /etc/sudoers.d/temp-pacman-nopasswd
//
createDirs().catch(console.error);
installPrograms(distro).catch(console.error);
