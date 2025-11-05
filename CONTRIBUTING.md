# Contributing to Circular Protocol Canonacle

Thank you for your interest in contributing! This document provides guidelines for contributing to the Canonacle project.

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/download.html) for installing Nickel
- [Just](https://github.com/casey/just) command runner
- Git for version control
- Basic understanding of [Nickel language](https://nickel-lang.org/)

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/circular-protocol/circular-canonacle.git
cd circular-canonacle

# Install Nickel via Nix
nix shell nixpkgs#nickel

# Run initial setup
just setup

# Verify environment
just check-env
```

## Development Workflow

### Making Changes

1. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

2. **Make your changes** following our coding standards (see below)

3. **Validate your changes**:
   ```bash
   # Type check
   just validate

   # Run tests
   just test

   # Generate artifacts
   just generate
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "type(scope): description"
   ```

   See [Commit Message Format](#commit-message-format) below.

5. **Push and create a PR**:
   ```bash
   git push origin your-branch-name
   # Then create a Pull Request on GitHub
   ```

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build, etc.)

**Examples:**
```
feat(api): add getAsset endpoint with contract validation

fix(generators): correct TypeScript type mapping for optional fields

docs: add examples for custom contract creation

test(contracts): add validation tests for Address contract
```

## Coding Standards

### Nickel Code Style

1. **Indentation**: 2 spaces (enforced by `.editorconfig`)

2. **Naming**:
   - Types and Contracts: `PascalCase` (e.g., `Address`, `Blockchain`)
   - Fields and functions: `camelCase` (e.g., `checkWallet`, `getAsset`)
   - Constants: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_TIMEOUT`)

3. **Contracts**:
   - Always provide helpful error messages
   - Use `std.contract.blame_with_message` for custom validation
   - Document what the contract validates

   ```nickel
   Address = std.contract.from_predicate (fun value =>
     if not (std.is_string value) then
       std.contract.blame_with_message "Address must be a string" value
     else if std.string.length value != 64 && std.string.length value != 66 then
       std.contract.blame_with_message "Address must be 64 or 66 characters" value
     else
       true
   )
   ```

4. **Documentation**:
   - Add docstrings using `| doc "..."` for all public APIs
   - Include parameter descriptions
   - Provide examples

5. **File Organization**:
   - One logical grouping per file (e.g., all wallet operations in `wallet.ncl`)
   - Import types at the top: `let types = import "../schemas/types.ncl" in`
   - Keep files under 500 lines

### Testing Requirements

All changes must include appropriate tests:

1. **Contract tests** (`tests/contracts/*.test.ncl`):
   - Test valid cases
   - Document expected failures (but comment them out to avoid breaking build)

2. **Generator tests** (automatically run via `just test-generators`):
   - Ensure generated code is syntactically valid
   - Update snapshots if intentional changes: `just update-snapshots`

3. **Integration tests** (when applicable):
   - Test against mock server or reference implementation

### Adding a New API Endpoint

Follow this checklist:

- [ ] 1. Define endpoint in `src/api/<domain>.ncl`:
  ```nickel
  newEndpoint = {
    method = "POST",
    path = "/newEndpoint",
    summary = "Brief description",
    description = "Detailed description",
    parameters = { ... },
    request_body = { ... },
    response_schema = { ... },
    example_request = { ... },
    example_response = { ... },
  }
  ```

- [ ] 2. Add types to `src/schemas/types.ncl` if needed

- [ ] 3. Create contract tests in `tests/contracts/`

- [ ] 4. Update `docs/API_REFERENCE.md`

- [ ] 5. Update generators to include new endpoint:
  - `generators/openapi.ncl`
  - `generators/typescript-sdk.ncl`
  - etc.

- [ ] 6. Run `just validate && just test && just generate`

- [ ] 7. Verify generated outputs are correct

- [ ] 8. Update `CHANGELOG.md` under `[Unreleased]`

### Pull Request Process

1. **Ensure all tests pass**:
   ```bash
   just ci
   ```

2. **Update documentation** if needed:
   - API changes → `docs/API_REFERENCE.md`
   - New patterns → `docs/NICKEL_PATTERNS.md`
   - Process changes → `docs/DEVELOPMENT_WORKFLOW.md`

3. **Update CHANGELOG.md** under `[Unreleased]` section

4. **Create PR** with clear description:
   - What changed and why
   - How to test the changes
   - Any breaking changes or migration notes

5. **Request review** from maintainers

6. **Address feedback** and update PR as needed

## Code Review Guidelines

### As a Reviewer

- ✅ Check contract validation is thorough
- ✅ Verify error messages are helpful
- ✅ Ensure tests cover new functionality
- ✅ Confirm generated code is correct
- ✅ Look for potential breaking changes
- ✅ Verify documentation is updated

### As a PR Author

- ✅ Respond to all comments
- ✅ Mark conversations as resolved after addressing
- ✅ Re-request review after major changes
- ✅ Keep PR focused on one logical change

## Getting Help

- **Documentation**: See `docs/` directory
- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue
- **Chat**: Join our Discord (link in README)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
