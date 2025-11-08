# GitHub Actions CI/CD Generator for TypeScript
# Generates .github/workflows/test.yml for automated testing and publishing

let config = import "../../../src/config.ncl" in

let workflow = {
  name = "Test and Build",

  on = {
    push = {
      branches = ["main", "development"],
    },
    pull_request = {
      branches = ["main", "development"],
    },
  },

  jobs = {
    test = {
      "runs-on" = "ubuntu-latest",

      strategy = {
        matrix = {
          "node-version" = ["16.x", "18.x", "20.x"],
        },
      },

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Node.js ${{ matrix.node-version }}",
          uses = "actions/setup-node@v4",
          "with" = {
            "node-version" = "${{ matrix.node-version }}",
            cache = "npm",
          },
        },
        {
          name = "Install dependencies",
          run = "npm ci",
        },
        {
          name = "Run linter",
          run = "npm run lint",
          continue-on-error = true,
        },
        {
          name = "Type check",
          run = "npx tsc --noEmit",
        },
        {
          name = "Run tests",
          run = "npm test",
        },
        {
          name = "Build package",
          run = "npm run build",
        },
      ],
    },

    publish-alpha = {
      "runs-on" = "ubuntu-latest",
      needs = "test",
      "if" = "github.ref == 'refs/heads/development' && github.event_name == 'push'",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Node.js",
          uses = "actions/setup-node@v4",
          "with" = {
            "node-version" = "20.x",
            registry-url = "https://registry.npmjs.org/",
          },
        },
        {
          name = "Install dependencies",
          run = "npm ci",
        },
        {
          name = "Build package",
          run = "npm run build",
        },
        {
          name = "Publish to npm (alpha)",
          run = "npm publish --tag alpha",
          env = {
            NODE_AUTH_TOKEN = "${{ secrets.NPM_TOKEN }}",
          },
          continue-on-error = true,
        },
      ],
    },

    publish-production = {
      "runs-on" = "ubuntu-latest",
      needs = "test",
      "if" = "github.ref == 'refs/heads/main' && github.event_name == 'push'",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Node.js",
          uses = "actions/setup-node@v4",
          "with" = {
            "node-version" = "20.x",
            registry-url = "https://registry.npmjs.org/",
          },
        },
        {
          name = "Install dependencies",
          run = "npm ci",
        },
        {
          name = "Build package",
          run = "npm run build",
        },
        {
          name = "Publish to npm (latest)",
          run = "npm publish",
          env = {
            NODE_AUTH_TOKEN = "${{ secrets.NPM_TOKEN }}",
          },
        },
      ],
    },
  },
} in

{
  workflow_yaml = std.serialize 'Yaml workflow,
}
