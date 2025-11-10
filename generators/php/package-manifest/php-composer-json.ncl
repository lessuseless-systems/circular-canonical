# Composer Package Manifest Generator for PHP SDK

let app_config = import "../../../src/config.ncl" in

{
  composer_json = {
    name = "circular/protocol-api",
    description = "Official PHP SDK for Circular Protocol blockchain operations and wallet management",
    version = app_config.version,
    type = "library",
    keywords = ["blockchain", "circular", "protocol", "sdk", "api", "crypto", "web3"],
    homepage = "https://github.com/circular-protocol/circular-canonical",
    license = "MIT",
    authors = [
      {
        name = "Danny De Novi",
        email = "dev@circular.org",
      },
    ],
    require = {
      php = "^8.0",
      "ext-curl" = "*",
      "ext-json" = "*",
    },
    "require-dev" = {
      phpunit = "^10.0",
      "phpstan/phpstan" = "^1.10",
      "squizlabs/php_codesniffer" = "^3.7",
    },
    autoload = {
      "psr-4" = {
        "Circular\\Protocol\\" = "src/",
      },
    },
    "autoload-dev" = {
      "psr-4" = {
        "Circular\\Protocol\\Tests\\" = "tests/",
      },
    },
    scripts = {
      test = "phpunit",
      "test:coverage" = "phpunit --coverage-html coverage",
      phpstan = "phpstan analyse src tests",
      "cs:check" = "phpcs src tests",
      "cs:fix" = "phpcbf src tests",
    },
    config = {
      "sort-packages" = true,
    },
    minimum-stability = "stable",
    prefer-stable = true,
  },
}
