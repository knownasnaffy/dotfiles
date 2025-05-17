import installArchPackages from "./arch";

export default async function installPrograms(distro?: string) {
  if (!distro) {
    return console.error(
      "Couldn't determine you linux distro, skipping program installation",
    );
  } else if (distro === "Arch Linux") {
    installArchPackages();
  }
}
