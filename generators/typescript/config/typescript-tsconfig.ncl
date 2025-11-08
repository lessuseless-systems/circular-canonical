# TypeScript Compiler Configuration Generator
# Generates tsconfig.json for TypeScript SDK

let config = import "../../../src/config.ncl" in

{
  compilerOptions = {
    # Target and Module
    target = "ES2020",
    module = "ESNext",
    lib = ["ES2020"],

    # Module Resolution
    moduleResolution = "node",
    resolveJsonModule = true,
    esModuleInterop = true,
    allowSyntheticDefaultImports = true,

    # Output Configuration
    outDir = "./lib",
    declarationDir = "./lib",
    declaration = true,
    declarationMap = true,
    sourceMap = true,

    # Strict Type-Checking Options
    strict = true,
    noImplicitAny = true,
    strictNullChecks = true,
    strictFunctionTypes = true,
    strictBindCallApply = true,
    strictPropertyInitialization = true,
    noImplicitThis = true,
    alwaysStrict = true,

    # Additional Checks
    noUnusedLocals = true,
    noUnusedParameters = true,
    noImplicitReturns = true,
    noFallthroughCasesInSwitch = true,
    noUncheckedIndexedAccess = true,
    noImplicitOverride = true,

    # Other Options
    skipLibCheck = true,
    forceConsistentCasingInFileNames = true,
    allowUnreachableCode = false,
    allowUnusedLabels = false,
    exactOptionalPropertyTypes = true,

    # Emit Options
    removeComments = false,
    preserveConstEnums = true,

    # Interop Constraints
    isolatedModules = true,
  },

  include = [
    "src/**/*",
  ],

  exclude = [
    "node_modules",
    "lib",
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts",
  ],
}
