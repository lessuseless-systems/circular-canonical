{
  description = "Circular Protocol Canonical - API Specification & SDK Generators";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python with required packages
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          requests
          pytest
          mypy
          types-requests
        ]);

        # Node.js with TypeScript
        nodeDeps = with pkgs.nodePackages; [
          typescript
          typescript-language-server
        ];

      in
      {
        # Development shell with all tools
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Nickel language
            nickel

            # JavaScript/TypeScript ecosystem
            nodejs_20
            nodePackages.npm
          ] ++ nodeDeps ++ [

            # Python ecosystem
            pythonEnv

            # Build tools
            just
            jq
            curl

            # Additional utilities
            git
            gh
          ];

          shellHook = ''
            echo "🔵 Circular Protocol Canonical Development Environment"
            echo ""
            echo "Available tools:"
            echo "  nickel:     $(nickel --version)"
            echo "  node:       $(node --version)"
            echo "  typescript: $(tsc --version)"
            echo "  python:     $(python3 --version)"
            echo "  just:       $(just --version)"
            echo ""
            echo "Quick start:"
            echo "  just help           - Show all available commands"
            echo "  just dev            - Validate + generate artifacts"
            echo "  just test           - Run all tests"
            echo "  just generate-ts    - Generate TypeScript SDK"
            echo "  just generate-py    - Generate Python SDK"
            echo ""
            echo "📚 Documentation: docs/"
            echo "✨ Happy hacking!"
          '';
        };

        # Packages that can be built
        packages = {
          # OpenAPI specification
          openapi-spec = pkgs.stdenv.mkDerivation {
            name = "circular-canonical-openapi";
            version = "1.0.8";
            src = ./.;

            buildInputs = [ pkgs.nickel pkgs.jq ];

            buildPhase = ''
              mkdir -p $out
              nickel export generators/openapi.ncl --format json > $out/openapi.json
              nickel export generators/openapi.ncl --format yaml > $out/openapi.yaml
            '';

            installPhase = ''
              echo "OpenAPI spec generated"
            '';
          };
        };

        # CI/CD checks
        checks = {
          # Type contract tests
          test-contracts = pkgs.stdenv.mkDerivation {
            name = "canonical-contract-tests";
            src = ./.;
            buildInputs = [ pkgs.nickel ];
            buildPhase = ''
              export HOME=$TMPDIR
              ${pkgs.bash}/bin/bash scripts/test.sh
            '';
            installPhase = ''
              mkdir -p $out
              echo "Tests passed" > $out/result
            '';
          };

          # Validate Nickel files typecheck
          validate-nickel = pkgs.stdenv.mkDerivation {
            name = "canonical-validate";
            src = ./.;
            buildInputs = [ pkgs.nickel ];
            buildPhase = ''
              find src generators -name "*.ncl" -exec nickel typecheck {} \;
            '';
            installPhase = ''
              mkdir -p $out
              echo "Validation passed" > $out/result
            '';
          };
        };

        # Default package
        packages.default = self.packages.${system}.openapi-spec;
      }
    );
}
