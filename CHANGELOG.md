# Changelog

All notable changes to the Circular Protocol Canonacle project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project scaffolding
- Complete directory structure for Canonacle project
- Nickel type system with core contracts (Address, Amount, Blockchain, etc.)
- API skeleton files for all domains:
  - Wallet operations (6 endpoints)
  - Transaction operations (6 endpoints)
  - Asset operations (4 endpoints)
  - Block operations (4 endpoints)
  - Domain resolution (1 endpoint)
  - Network queries (1 endpoint)
  - Smart contracts (2 endpoints)
- Comprehensive API reference extracted from circular-js v1.0.8
- Build automation with justfile
- Testing infrastructure:
  - Contract validation test runner
  - Generator syntax validation
  - Snapshot testing
  - Cross-language test harness (skeleton)
  - Regression testing (skeleton)
- CI/CD workflows:
  - Automated testing on push/PR
  - Release automation
- Development documentation:
  - WEEK_1_2_GUIDE.md: Day-by-day implementation plan
  - NICKEL_PATTERNS.md: Comprehensive syntax and patterns guide
  - TESTING_STRATEGY.md: Four-layer testing approach
  - DEVELOPMENT_WORKFLOW.md: Day-to-day development process
  - MIGRATION_PATH.md: 24-week transition strategy
  - API_REFERENCE.md: Complete API documentation
- Git hooks for pre-commit validation
- Example contract test file

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- N/A (initial release)

---

## [2.0.0-alpha.1] - TBD

### Planned
- Complete implementation of checkWallet endpoint
- OpenAPI 3.0 generator
- TypeScript SDK generator
- Contract validation for all core types
- First working generated artifacts

**Note:** This version represents the first milestone of the Canonacle project.
See docs/WEEK_1_2_GUIDE.md for implementation timeline.

---

## Version Scheme

**Major.Minor.Patch[-PreRelease]**

- **Major**: Breaking changes to API or contracts
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, no API changes
- **PreRelease**: alpha, beta, rc (release candidate)

### Examples:
- `2.0.0-alpha.1`: First alpha release of v2
- `2.0.0-beta.1`: First beta release
- `2.0.0`: Stable release
- `2.1.0`: New features added
- `2.1.1`: Bug fixes

---

## Migration from circular-js

The Canonacle project represents a complete redesign of the Circular Protocol SDK:

**circular-js v1.0.8** → **Canonacle v2.0.0**

Key improvements:
- Single source of truth (Nickel definitions)
- Automated code generation
- Comprehensive testing
- Multi-language consistency
- AI-friendly (OpenAPI, MCP, AGENTS.md)

See [MIGRATION_PATH.md](docs/MIGRATION_PATH.md) for detailed migration guide.

---

## How to Release

1. Update version in `src/config.ncl`
2. Update this CHANGELOG.md (move Unreleased to new version)
3. Commit: `git commit -m "chore(release): prepare vX.Y.Z"`
4. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
5. Push: `git push origin develop && git push origin vX.Y.Z`
6. CI/CD will create GitHub release automatically

---

[Unreleased]: https://github.com/circular-protocol/circular-canonacle/compare/v2.0.0-alpha.1...HEAD
[2.0.0-alpha.1]: https://github.com/circular-protocol/circular-canonacle/releases/tag/v2.0.0-alpha.1
