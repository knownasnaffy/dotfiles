/**
 * Dotfiles Manager
 * A modern, maintainable dotfiles management system
 */

// Export all interfaces
export * from "./config/config-manager.interface.js";
export * from "./platform/platform-handler.interface.js";
export * from "./package/package-manager.interface.js";
export * from "./symlink/symlink-manager.interface.js";
export * from "./sudo/sudo-manager.interface.js";
export * from "./logger/logger.interface.js";
export * from "./orchestrator/orchestrator.interface.js";

// Export types
export * from "./types/index.js";

// Main entry point
async function main() {
  // Implementation will be added in future tasks
  console.log("Dotfiles Manager - Setup in progress");
}

// Run the main function if this is the entry point
if (import.meta.main) {
  main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
}
