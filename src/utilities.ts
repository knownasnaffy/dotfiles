import { $ } from "bun";

export async function detectDistro(): Promise<string | undefined> {
  const os = await Bun.file("/etc/os-release").text();
  const info = Object.fromEntries(
    os
      .split("\n")
      .filter((line) => line.includes("="))
      .map((line) => {
        const [key, value] = line.split("=");
        return [key, value?.replace(/^"|"$/g, "")]; // remove quotes
      }),
  );
  return info["NAME"];
}

export async function commandExists(cmd: string): Promise<boolean> {
  try {
    await $`which ${cmd}`.quiet();
    return true;
  } catch {
    return false;
  }
}
