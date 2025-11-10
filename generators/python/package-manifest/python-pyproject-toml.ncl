# Python pyproject.toml Generator
# Generates modern Python package manifest for PyPI publication
# Reference: PEP 518, PEP 621 (modern Python packaging)

let config = import "../../../src/config.ncl" in

{
  # Build system (PEP 518)
  build-system = {
    requires = [
      "setuptools>=45",
      "wheel",
      "setuptools_scm>=6.2",
    ],
    build-backend = "setuptools.build_meta",
  },

  # Project metadata (PEP 621)
  project = {
    name = "circular-protocol-api",
    version = config.version,
    description = config.description,
    readme = "README.md",
    requires-python = ">=3.8",
    license = {
      text = "MIT",
    },
    authors = [
      {
        name = "Danny De Novi",
        email = "dannydnc@protonmail.com",
      },
    ],
    keywords = [
      "blockchain",
      "circular",
      "protocol",
      "smart-contracts",
      "web3",
      "sdk",
      "api",
      "python",
    ],
    classifiers = [
      "Development Status :: 3 - Alpha",
      "Intended Audience :: Developers",
      "License :: OSI Approved :: MIT License",
      "Programming Language :: Python :: 3",
      "Programming Language :: Python :: 3.8",
      "Programming Language :: Python :: 3.9",
      "Programming Language :: Python :: 3.10",
      "Programming Language :: Python :: 3.11",
      "Programming Language :: Python :: 3.12",
      "Topic :: Software Development :: Libraries :: Python Modules",
      "Topic :: Internet :: WWW/HTTP",
      "Topic :: System :: Distributed Computing",
    ],

    # Runtime dependencies
    dependencies = [
      "requests>=2.28.0",
      "ecdsa>=0.18.0",
      "typing-extensions>=4.5.0;python_version<'3.10'",
    ],

    # Optional dependencies
    optional-dependencies = {
      async = [
        "aiohttp>=3.8.0",
      ],
      dev = [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "pytest-asyncio>=0.21.0",
        "black>=22.0.0",
        "mypy>=1.0.0",
        "ruff>=0.0.270",
        "types-requests>=2.28.0",
      ],
      docs = [
        "sphinx>=5.0.0",
        "sphinx-rtd-theme>=1.2.0",
      ],
    },
  },

  # Project URLs
  project.urls = {
    Homepage = "https://github.com/circular-protocol/circular-protocol-py",
    Documentation = "https://docs.circular.org",
    Repository = "https://github.com/circular-protocol/circular-protocol-py",
    Issues = "https://github.com/circular-protocol/circular-protocol-py/issues",
    Changelog = "https://github.com/circular-protocol/circular-protocol-py/blob/main/CHANGELOG.md",
  },

  # Tool configurations
  tool = {
    # Setuptools configuration
    setuptools = {
      packages = {
        find = {
          where = ["src"],
        },
      },
      package-dir = {
        "" = "src",
      },
    },

    # Black code formatter
    black = {
      line-length = 100,
      target-version = ["py38", "py39", "py310", "py311", "py312"],
      include = "\\.pyi?$",
    },

    # Ruff linter
    ruff = {
      line-length = 100,
      target-version = "py38",
      select = [
        "E",   # pycodestyle errors
        "W",   # pycodestyle warnings
        "F",   # pyflakes
        "I",   # isort
        "B",   # flake8-bugbear
        "C4",  # flake8-comprehensions
        "UP",  # pyupgrade
      ],
      ignore = [
        "E501",  # line too long (handled by black)
      ],
    },

    # MyPy type checker
    mypy = {
      python_version = "3.8",
      warn_return_any = true,
      warn_unused_configs = true,
      disallow_untyped_defs = true,
      disallow_incomplete_defs = true,
      check_untyped_defs = true,
      no_implicit_optional = true,
      warn_redundant_casts = true,
      warn_unused_ignores = true,
      warn_no_return = true,
      strict_equality = true,
    },

    # Pytest configuration
    pytest = {
      ini_options = {
        testpaths = ["tests"],
        python_files = ["test_*.py", "*_test.py"],
        python_classes = ["Test*"],
        python_functions = ["test_*"],
        addopts = [
          "--strict-markers",
          "--strict-config",
          "--cov=circular_protocol_api",
          "--cov-report=term-missing",
          "--cov-report=html",
        ],
        markers = [
          "unit: Unit tests",
          "integration: Integration tests",
          "asyncio: Async tests",
        ],
      },
    },

    # Coverage configuration
    coverage = {
      run = {
        source = ["src"],
        branch = true,
      },
      report = {
        exclude_lines = [
          "pragma: no cover",
          "def __repr__",
          "raise AssertionError",
          "raise NotImplementedError",
          "if __name__ == .__main__.:",
          "if TYPE_CHECKING:",
        ],
      },
    },
  },
}
