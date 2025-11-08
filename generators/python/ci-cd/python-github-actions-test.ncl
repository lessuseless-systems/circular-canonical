# GitHub Actions CI/CD Generator for Python
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
          "python-version" = ["3.8", "3.9", "3.10", "3.11", "3.12"],
        },
      },

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Python ${{ matrix.python-version }}",
          uses = "actions/setup-python@v5",
          "with" = {
            "python-version" = "${{ matrix.python-version }}",
          },
        },
        {
          name = "Install dependencies",
          run = "pip install -e .[dev]",
        },
        {
          name = "Run linter (ruff)",
          run = "ruff check src/",
          continue-on-error = true,
        },
        {
          name = "Type check (mypy)",
          run = "mypy src/ --strict",
          continue-on-error = true,
        },
        {
          name = "Run tests",
          run = "pytest -v",
        },
        {
          name = "Build package",
          run = "python -m build",
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
          name = "Setup Python",
          uses = "actions/setup-python@v5",
          "with" = {
            "python-version" = "3.11",
          },
        },
        {
          name = "Install build tools",
          run = "pip install build twine",
        },
        {
          name = "Build package",
          run = "python -m build",
        },
        {
          name = "Publish to PyPI (alpha)",
          run = "twine upload dist/* --skip-existing",
          env = {
            TWINE_USERNAME = "__token__",
            TWINE_PASSWORD = "${{ secrets.PYPI_TOKEN }}",
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
          name = "Setup Python",
          uses = "actions/setup-python@v5",
          "with" = {
            "python-version" = "3.11",
          },
        },
        {
          name = "Install build tools",
          run = "pip install build twine",
        },
        {
          name = "Build package",
          run = "python -m build",
        },
        {
          name = "Publish to PyPI (latest)",
          run = "twine upload dist/*",
          env = {
            TWINE_USERNAME = "__token__",
            TWINE_PASSWORD = "${{ secrets.PYPI_TOKEN }}",
          },
        },
      ],
    },
  },
} in

{
  workflow_yaml = std.serialize 'Yaml workflow,
}
