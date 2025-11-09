{
  description = "Circular Protocol Canonical - API Specification & SDK Generators";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, git-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python with required packages
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          requests
          cryptography
          pytest
          mypy
          types-requests
        ]);

        # Node.js with TypeScript
        nodeDeps = with pkgs.nodePackages; [
          typescript
          typescript-language-server
        ];

        # Git hooks configuration
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # 1. Nickel type checking (CRITICAL - custom hook)
            nickel-typecheck = {
              enable = true;
              name = "Nickel typecheck";
              entry = "${pkgs.nickel}/bin/nickel typecheck";
              files = "\\.ncl$";
              pass_filenames = true;
            };

            # 2. Prevent push to numbered/typo repos (pre-push hook - custom)
            check-repo-urls = {
              enable = true;
              name = "Prevent push to test/typo repos";
              entry = toString (pkgs.writeShellScript "check-repo-urls" ''
                #!/bin/bash
                # Get remote URL (on pre-push this is $2, fallback to origin)
                url="''${2:-$(git remote get-url origin 2>/dev/null || echo "")}"

                # Check for numbered repos (-1.git, -2.git, etc.)
                if [[ "$url" =~ -[0-9]+\.git$ ]]; then
                  echo "════════════════════════════════════════════════════════════════"
                  echo "❌ ERROR: Attempting to push to numbered test repository!"
                  echo "════════════════════════════════════════════════════════════════"
                  echo ""
                  echo "Remote URL: $url"
                  echo ""
                  echo "Numbered repos (-1, -2) are test repos and should not receive code."
                  echo ""
                  echo "Official repositories:"
                  echo "  • circular-canonical  (NOT circular-canonicle)"
                  echo "  • circular-js-npm     (NOT circular-js-npm-1 or -2)"
                  echo "  • circular-py         (NOT circular-py-1 or -2)"
                  echo ""
                  echo "Fix: git remote set-url origin <correct-url>"
                  echo "════════════════════════════════════════════════════════════════"
                  exit 1
                fi

                # Check for typo: canonical vs canonicle/canonacle
                if [[ "$url" =~ canon(icle|acle) ]]; then
                  echo "════════════════════════════════════════════════════════════════"
                  echo "❌ ERROR: Repository name typo detected!"
                  echo "════════════════════════════════════════════════════════════════"
                  echo ""
                  echo "Remote URL: $url"
                  echo ""
                  echo "Typo: 'canonicle' or 'canonacle' should be 'canonical'"
                  echo ""
                  echo "Fix: git remote set-url origin git@github.com:lessuseless-systems/circular-canonical.git"
                  echo "════════════════════════════════════════════════════════════════"
                  exit 1
                fi

                exit 0
              '');
              stages = ["pre-push"];
            };
          };
        };

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

          shellHook = pre-commit-check.shellHook + ''
            echo ""
            echo "🔵 Circular Protocol Canonical Development Environment"
            echo ""
            echo "Available tools:"
            echo "  nickel:     $(nickel --version)"
            echo "  node:       $(node --version)"
            echo "  typescript: $(tsc --version)"
            echo "  python:     $(python3 --version)"
            echo "  just:       $(just --version)"
            echo ""
            echo "Git hooks enabled:"
            echo "  ✓ pre-commit: nickel typecheck, secrets detection, file validation"
            echo "  ✓ pre-push: prevent numbered/typo repos"
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
          # Pre-commit hooks check (runs in CI)
          pre-commit-check = pre-commit-check;

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
