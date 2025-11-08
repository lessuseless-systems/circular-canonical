# Jest Configuration Generator for TypeScript
# Generates jest.config.js for TypeScript SDK testing

let config = import "../../../src/config.ncl" in

# Generate JavaScript module export format
let js_config = {
  preset = "ts-jest",
  testEnvironment = "node",

  # Root directory
  rootDir = ".",
  roots = ["<rootDir>"],

  # Test match patterns
  testMatch = [
    "**/__tests__/**/*.ts",
    "**/?(*.)+(spec|test).ts",
  ],

  # Transform TypeScript files with ts-jest config
  transform = {
    "^.+\\.ts$" = [
      "ts-jest",
      {
        tsconfig = {
          esModuleInterop = true,
          allowSyntheticDefaultImports = true,
        },
      },
    ],
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

  # Ignore patterns (relative to project root, not absolute paths)
  testPathIgnorePatterns = [
    "/node_modules/",
    "<rootDir>/lib/",
  ],

  # Verbose output
  verbose = true,
} in

# Format as JavaScript module.exports
m%"module.exports = %{std.serialize 'Json js_config};"%
