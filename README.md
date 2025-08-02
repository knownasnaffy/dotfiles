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

## Testing

This project uses [Vitest](https://vitest.dev/) as the standard testing framework. All tests should be written using Vitest.

### Running Tests

```bash
# Run all tests once
bun run test

# Run tests in watch mode (re-runs on file changes)
bun run test:watch

# Run tests with coverage
bun run test -- --coverage
```

### Writing Tests

Tests are located in the `tests/` directory and follow the pattern `*.test.ts`. Here's how to write tests with Vitest:

#### Basic Test Structure

```typescript
import { describe, it, expect, beforeEach, vi } from "vitest";
import { YourClass } from "../../../src/your-module";

describe("YourClass", () => {
  let instance: YourClass;

  beforeEach(() => {
    instance = new YourClass();
    vi.clearAllMocks();
  });

  it("should do something", () => {
    const result = instance.doSomething();
    expect(result).toBe("expected value");
  });
});
```

#### Mocking with Vitest

```typescript
// Mock a function
const mockFn = vi.fn(() => "mocked return value");

// Mock a module
vi.mock("fs/promises", () => ({
  readFile: vi.fn(),
  writeFile: vi.fn(),
}));

// Mock implementation
mockFn.mockImplementation(() => "new implementation");

// Assertions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith("expected argument");
expect(mockFn).toHaveBeenCalledTimes(1);
```

#### Async Testing

```typescript
it("should handle async operations", async () => {
  const result = await instance.asyncMethod();
  expect(result).toBe("expected value");
});

it("should handle promise rejections", async () => {
  await expect(instance.failingMethod()).rejects.toThrow("Expected error");
});
```

### Test Configuration

The project uses `vitest.config.ts` for test configuration:

- Tests are located in `tests/**/*.test.ts`
- Node environment is used for testing
- Coverage reports are generated with v8 provider
- Global test utilities are available (no need to import `describe`, `it`, `expect`)

### Best Practices

1. **Use descriptive test names**: Test names should clearly describe what is being tested
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Mock external dependencies**: Use `vi.mock()` to isolate units under test
4. **Clean up after tests**: Use `beforeEach` and `afterEach` to reset state
5. **Test both success and error cases**: Ensure comprehensive coverage
6. **Use TypeScript**: All tests should be written in TypeScript with proper typing

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
