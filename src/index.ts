import createDirs from "./directories";
import installPrograms from "./programs";
import { detectDistro } from "./utilities";
import determineTemplate from "./determine-template";

const hasInteractiveFlag = process.argv.includes("-i");

const distro: string | undefined = await detectDistro();

const template = hasInteractiveFlag ? await determineTemplate() : "headless";
console.log(template);

createDirs().catch(console.error);
installPrograms(distro).catch(console.error);
