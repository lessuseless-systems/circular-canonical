# TODO: Shared README Header Template
# Generates common header section for all language READMEs
# Includes: Title, badges, description

# Usage in language-specific README:
# let header = import "../../../shared/templates/readme-header.todo.ncl" in
# header.generate { language = "TypeScript", package_name = "circular-protocol-api" }

{
  generate = fun config =>
    m%"
    # Circular Protocol API - %{config.language} SDK

    [![npm version](https://img.shields.io/npm/v/%{config.package_name}.svg)]...
    [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]...

    > Official %{config.language} SDK for Circular Protocol blockchain
    "%
}
