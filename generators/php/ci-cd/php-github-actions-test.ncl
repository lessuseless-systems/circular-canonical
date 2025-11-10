# GitHub Actions CI/CD Generator for PHP
# Generates .github/workflows/test.yml for automated testing and code quality

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
          "php-version" = ["8.0", "8.1", "8.2", "8.3"],
        },
      },

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup PHP ${{ matrix.php-version }}",
          uses = "shivammathur/setup-php@v2",
          "with" = {
            "php-version" = "${{ matrix.php-version }}",
            extensions = "curl, json, mbstring",
            coverage = "xdebug",
          },
        },
        {
          name = "Validate composer.json",
          run = "composer validate --strict",
        },
        {
          name = "Cache Composer dependencies",
          uses = "actions/cache@v4",
          "with" = {
            path = "vendor",
            key = "${{ runner.os }}-php-${{ hashFiles('**/composer.lock') }}",
            "restore-keys" = "${{ runner.os }}-php-",
          },
        },
        {
          name = "Install dependencies",
          run = "composer install --prefer-dist --no-progress",
        },
        {
          name = "Run PHPStan (static analysis)",
          run = "composer phpstan",
          continue-on-error = true,
        },
        {
          name = "Run CodeSniffer (code style)",
          run = "composer cs:check",
          continue-on-error = true,
        },
        {
          name = "Run PHPUnit tests",
          run = "composer test",
        },
        {
          name = "Generate coverage report",
          run = "composer test:coverage",
          "if" = "matrix.php-version == '8.3'",
        },
      ],
    },

    code-quality = {
      "runs-on" = "ubuntu-latest",
      needs = "test",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup PHP",
          uses = "shivammathur/setup-php@v2",
          "with" = {
            "php-version" = "8.3",
            extensions = "curl, json",
          },
        },
        {
          name = "Install dependencies",
          run = "composer install --prefer-dist --no-progress",
        },
        {
          name = "Run PHPStan (strict)",
          run = "composer phpstan -- --error-format=github",
        },
        {
          name = "Check code style",
          run = "composer cs:check -- --report=checkstyle",
        },
      ],
    },

    publish-packagist = {
      "runs-on" = "ubuntu-latest",
      needs = ["test", "code-quality"],
      "if" = "(github.ref == 'refs/heads/main' || github.ref == 'refs/heads/development') && github.event_name == 'push'",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup PHP",
          uses = "shivammathur/setup-php@v2",
          "with" = {
            "php-version" = "8.3",
          },
        },
        {
          name = "Validate package",
          run = "composer validate --strict",
        },
        {
          name = "Create git tag (if version updated)",
          run = m%"
            VERSION=$(composer config version)
            if git rev-parse "v$VERSION" >/dev/null 2>&1; then
              echo "Tag v$VERSION already exists"
            else
              git tag "v$VERSION"
              git push origin "v$VERSION"
              echo "Created and pushed tag v$VERSION"
            fi
          "%,
          "if" = "github.ref == 'refs/heads/main'",
          continue-on-error = true,
        },
        {
          name = "Trigger Packagist webhook",
          run = m%"curl -X POST \"https://packagist.org/api/update-package?username=${{ secrets.PACKAGIST_USERNAME }}&apiToken=${{ secrets.PACKAGIST_TOKEN }}\""%,
          continue-on-error = true,
        },
      ],
    },
  },
} in

{
  workflow_yaml = std.serialize 'Yaml workflow,
}
