# Jest Configuration Generator for TypeScript
# Generates jest.config.js for TypeScript SDK testing

let config = import "../../../src/config.ncl" in

# Generate JavaScript module export format
let js_config = {
  preset = "ts-jest",
  testEnvironment = "node",

  # Root directory
  rootDir = ".",

  # Test match patterns
  testMatch = [
    "**/__tests__/**/*.ts",
    "**/?(*.)+(spec|test).ts",
  ],

  # Transform TypeScript files
  transform = {
    "^.+\\.ts$" = "ts-jest",
  },

  # Module file extensions
  moduleFileExtensions = [
    "ts",
    "tsx",
    "js",
    "jsx",
    "json",
    "node",
  ],

  # Coverage configuration
  collectCoverageFrom = [
    "src/**/*.ts",
    "!src/**/*.d.ts",
    "!src/**/*.test.ts",
    "!src/**/*.spec.ts",
  ],

  coverageDirectory = "coverage",

  coverageThreshold = {
    global = {
      branches = 80,
      functions = 80,
      lines = 80,
      statements = 80,
    },
  },

  # Coverage reporters
  coverageReporters = [
    "text",
    "text-summary",
    "html",
    "lcov",
  ],

  # Ignore patterns
  testPathIgnorePatterns = [
    "/node_modules/",
    "/lib/",
    "/dist/",
  ],

  # Verbose output
  verbose = true,

  # TypeScript-specific configurations
  globals = {
    "ts-jest" = {
      tsconfig = {
        esModuleInterop = true,
        allowSyntheticDefaultImports = true,
      },
      useESM = true,
    },
  },

  # ESM support
  extensionsToTreatAsEsm = [".ts"],

  # Use node --experimental-vm-modules
  testEnvironmentOptions = {
    url = "http://localhost",
  },
} in

# Format as JavaScript module.exports
m%"module.exports = %{std.serialize 'Json js_config};"%
