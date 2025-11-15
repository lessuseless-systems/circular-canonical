# Shared Renovate Configuration Generator
# Generates renovate.json for automated dependency updates across all SDK languages

let config = import "../../../src/config.ncl" in

{
  # Base Renovate configuration (language-agnostic)
  base_renovate_config = {
    "$schema" = "https://docs.renovatebot.com/renovate-schema.json",
    "extends" = [
      "config:base",
      ":dependencyDashboard",
      ":semanticCommits",
      ":separateMajorReleases",
    ],
    "labels" = ["dependencies"],
    "assignees" = [],
    "reviewers" = [],
    "schedule" = ["before 10am on Monday"],
    "timezone" = "UTC",
    "prConcurrentLimit" = 5,
    "prCreation" = "immediate",
    "rangeStrategy" = "bump",
    "bumpVersion" = null,
    "commitMessagePrefix" = "chore(deps):",
    "commitMessageAction" = "update",
    "commitMessageTopic" = "{{depName}}",
    "commitMessageExtra" = "to {{#if isPinDigest}}{{{newDigestShort}}}{{else}}{{#if isMajor}}{{prettyNewMajor}}{{else}}{{#if isSingleVersion}}{{prettyNewVersion}}{{else}}{{#if newValue}}{{{newValue}}}{{else}}{{{newDigestShort}}}{{/if}}{{/if}}{{/if}}{{/if}}",
    "automerge" = false,
    "automergeType" = "pr",
    "packageRules" = [
      {
        "description" = "Group all non-major dependencies into a single PR",
        "matchUpdateTypes" = ["patch", "minor"],
        "groupName" = "all non-major dependencies",
        "groupSlug" = "all-minor-patch",
      },
      {
        "description" = "Separate major updates",
        "matchUpdateTypes" = ["major"],
        "labels" = ["dependencies", "major-update"],
      },
      {
        "description" = "Automerge patch updates",
        "matchUpdateTypes" = ["patch"],
        "automerge" = true,
      },
    ],
  },

  # TypeScript/Node.js specific config
  typescript_config = base_renovate_config & {
    "packageRules" = base_renovate_config.packageRules @ [
      {
        "description" = "Group TypeScript type definitions",
        "matchPackagePatterns" = ["^@types/"],
        "groupName" = "TypeScript type definitions",
        "automerge" = true,
      },
      {
        "description" = "Group testing libraries",
        "matchPackageNames" = ["jest", "@types/jest", "ts-jest"],
        "groupName" = "testing libraries",
      },
      {
        "description" = "Update Node.js to LTS only",
        "matchPackageNames" = ["node"],
        "allowedVersions" = "^16.0.0 || ^18.0.0 || ^20.0.0",
      },
    ],
  },

  # Python specific config
  python_config = base_renovate_config & {
    "packageRules" = base_renovate_config.packageRules @ [
      {
        "description" = "Group testing libraries",
        "matchPackageNames" = ["pytest", "pytest-cov", "pytest-asyncio"],
        "groupName" = "pytest packages",
      },
      {
        "description" = "Group linting/formatting tools",
        "matchPackageNames" = ["black", "ruff", "mypy"],
        "groupName" = "code quality tools",
      },
    ],
    "pip_requirements" = {
      "fileMatch" = ["^requirements.*\\.txt$"],
    },
  },

  # Go specific config
  go_config = base_renovate_config & {
    "packageRules" = base_renovate_config.packageRules @ [
      {
        "description" = "Update Go to stable versions only",
        "matchDatasources" = ["golang-version"],
        "allowedVersions" = ">=1.19",
      },
    ],
  },

  # PHP specific config
  php_config = base_renovate_config & {
    "packageRules" = base_renovate_config.packageRules @ [
      {
        "description" = "Group PHPUnit packages",
        "matchPackageNames" = ["phpunit/phpunit"],
        "groupName" = "PHPUnit",
      },
      {
        "description" = "Group code quality tools",
        "matchPackageNames" = ["squizlabs/php_codesniffer", "phpstan/phpstan"],
        "groupName" = "PHP code quality tools",
      },
    ],
  },

  # Dart specific config
  dart_config = base_renovate_config & {
    "packageRules" = base_renovate_config.packageRules @ [
      {
        "description" = "Group testing libraries",
        "matchPackageNames" = ["test", "mockito"],
        "groupName" = "Dart testing packages",
      },
      {
        "description" = "Update Dart SDK to stable only",
        "matchDatasources" = ["dart"],
        "allowedVersions" = ">=2.19.0",
      },
    ],
  },
}
