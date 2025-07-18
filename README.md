# Dotfiles Manager

A modern, maintainable dotfiles management system built with TypeScript and Bun.

## Features

- Multi-platform support (Arch Linux, Ubuntu)
- Template-based installation profiles (headless, desktop, personal)
- Intelligent symlink management with automatic backups
- Comprehensive error handling and logging
- Idempotent operations for safe re-runs

## Requirements

- [Bun](https://bun.sh/) runtime
- Linux environment (Arch or Ubuntu)

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Install dependencies
bun install

# Build the project
bun run build
```

## Usage

```bash
# Run with default settings (headless template)
bun start

# Run in interactive mode
bun start -- -i

# Specify a platform
bun start -- --arch
bun start -- --ubuntu

# Combine flags
bun start -- -i --arch
```

## Development

```bash
# Run in development mode with auto-reload
bun run dev

# Type checking
bun run check

# Format code
bun run format

# Lint code
bun run lint
```

## Project Structure

- `src/` - Source code
  - `config/` - Configuration management
  - `platform/` - Platform-specific handlers
  - `package/` - Package management
  - `symlink/` - Symlink management
  - `sudo/` - Sudo permission management
  - `logger/` - Logging system
  - `orchestrator/` - Main orchestration
  - `types/` - TypeScript type definitions

## Configuration

Configuration files are stored in the `config/` directory:

- `templates/` - Template definitions
  - `headless.json` - Headless server template
  - `desktop.json` - Desktop environment template
  - `personal.json` - Personal configuration template
- `packages.json` - Package definitions for different platforms
- `symlinks.json` - Symlink mapping definitions
- `post-install.json` - Post-installation tasks

## License

MIT