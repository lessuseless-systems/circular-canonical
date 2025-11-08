# TypeScript package.json Generator
# Generates complete package.json for npm publication
# Reference: circular-js-npm/package.json

let config = import "../../../src/config.ncl" in

{
  # Package identity
  name = "circular-protocol-api",
  version = config.version,
  description = config.description,

  # Package type and entry points
  type = "module",
  main = "./lib/index.js",

  # Dual CJS/ESM exports
  exports = {
    "." = {
      require = "./lib/index.cjs",
      "import" = "./lib/index.js",
    },
  },

  # Build and test scripts
  scripts = {
    "build:cjs" = "webpack --config webpack.config.cjs.js",
    "build:esm" = "webpack --config webpack.config.esm.js",
    "build" = "npm run build:cjs && npm run build:esm",
    test = "jest",
    "test:coverage" = "jest --coverage",
    "type-check" = "tsc --noEmit",
    lint = "eslint src/**/*.ts",
    format = "prettier --write \"src/**/*.ts\"",
  },

  # Repository information
  repository = {
    type = "git",
    url = "git+https://github.com/circular-protocol/circular-protocol-ts.git",
  },

  bugs = {
    url = "https://github.com/circular-protocol/circular-protocol-ts/issues",
  },

  homepage = "https://github.com/circular-protocol/circular-protocol-ts#readme",

  # Keywords for npm search
  keywords = [
    "Blockchain",
    "Circular",
    "Protocol",
    "Smart",
    "Contracts",
    "Web",
    "3.0",
    "SDK",
    "API",
    "TypeScript",
  ],

  # Author and license
  author = "Danny De Novi",
  license = "MIT",

  # Runtime dependencies
  dependencies = {
    elliptic = "^6.5.7",
    "node-fetch" = "^3.3.2",
    sha256 = "^0.2.0",
  },

  # Development dependencies
  devDependencies = {
    "@types/jest" = "^29.5.12",
    "@types/node" = "^20.12.7",
    "@typescript-eslint/eslint-plugin" = "^7.7.0",
    "@typescript-eslint/parser" = "^7.7.0",
    eslint = "^8.57.0",
    jest = "^29.7.0",
    nock = "^13.5.5",
    prettier = "^3.2.5",
    "ts-jest" = "^29.1.2",
    "ts-loader" = "^9.5.1",
    typescript = "^5.4.5",
    webpack = "^5.91.0",
    "webpack-cli" = "^5.1.4",
  },

  # Engine requirements
  engines = {
    node = ">=16.0.0",
  },

  # Files to include in npm package
  files = [
    "lib",
    "README.md",
    "LICENSE",
  ],
}
