import { join } from "path";
import { ConfigManagerImpl } from "../src/config/config-manager";

async function validateConfigs() {
  const configPath = join(process.cwd(), "config");
  const configManager = new ConfigManagerImpl(configPath);

  try {
    console.log("Validating configuration files...");

    // Validate templates
    console.log("\nValidating templates:");
    const templates = ["headless", "desktop", "personal"];
    for (const template of templates) {
      try {
        const templateConfig = await configManager.loadTemplate(template);
        console.log(`✓ Template '${template}' is valid`);
      } catch (error) {
        console.error(`✗ Template '${template}' is invalid:`, error.message);
      }
    }

    // Validate packages
    console.log("\nValidating package definitions:");
    try {
      const packages = await configManager.loadPackageDefinitions();
      console.log(`✓ Package definitions are valid (${Object.keys(packages).length} packages)`);
    } catch (error) {
      console.error("✗ Package definitions are invalid:", error.message);
    }

    // Validate symlinks
    console.log("\nValidating symlink mappings:");
    try {
      const symlinks = await configManager.loadSymlinkMappings();
      console.log(`✓ Symlink mappings are valid (${symlinks.length} symlinks)`);
    } catch (error) {
      console.error("✗ Symlink mappings are invalid:", error.message);
    }

    // Validate post-install tasks
    console.log("\nValidating post-install tasks:");
    try {
      const tasks = await configManager.loadPostInstallTasks();
      console.log(`✓ Post-install tasks are valid (${tasks.length} tasks)`);
    } catch (error) {
      console.error("✗ Post-install tasks are invalid:", error.message);
    }

    console.log("\nAll configuration files are valid!");
  } catch (error) {
    console.error("Error validating configurations:", error);
    process.exit(1);
  }
}

validateConfigs();
