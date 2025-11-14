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
          name = "Run unit tests",
          run = "pytest tests/test_unit.py -v",
        },
        {
          name = "Build package",
          run = "python -m build",
        },
      ],
    },

    e2e-tests = {
      "runs-on" = "ubuntu-latest",
      needs = "test",
      "if" = "github.event_name == 'push' || github.event_name == 'schedule'",

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
          name = "Install dependencies",
          run = "pip install -e .[dev]",
        },
        {
          name = "Run E2E tests (read-only)",
          run = "pytest tests/test_e2e.py -v -m e2e",
          env = {
            CIRCULAR_TEST_ADDRESS = "${{ secrets.CIRCULAR_TEST_ADDRESS }}",
            CIRCULAR_TEST_BLOCKCHAIN = "${{ secrets.CIRCULAR_TEST_BLOCKCHAIN }}",
            CIRCULAR_NAG_URL = "${{ secrets.CIRCULAR_NAG_URL }}",
            CIRCULAR_API_KEY = "${{ secrets.CIRCULAR_API_KEY }}",
          },
          continue-on-error = true,
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
