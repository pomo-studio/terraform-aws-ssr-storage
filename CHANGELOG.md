# Changelog

All notable changes to this module are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow [Semantic Versioning](https://semver.org/).

## [v0.2.5] - 2026-09-12

### Added

- terraform-docs-generated interface documentation in README (Requirements/Providers/Inputs/Outputs) with a CI drift check

## [v0.2.4] - 2026-09-07

### Changed

- README rewritten: what the module is for, how to use it, and what to watch out for. Documentation only; no configuration change.

## [v0.2.3] - 2026-09-07

### Changed

- Every input and output now carries a description, so the Registry renders complete Inputs and Outputs tables. Documentation only; no configuration change.

## [0.2.2] - 2026-09-05

### Added

- terraform-docs-generated interface documentation in README (Requirements/Providers/Inputs/Outputs) with a CI drift check

## [0.2.1] - 2026-09-05

### Added

- CHANGELOG.md

## [0.2.0] - 2026-09-04

### Added

- CI and release workflows (root validate uses a mocked `aws.dr` provider)
- `.tflint.hcl` configuration
- MIT LICENSE
- README badges
- Example `terraform` block
- Committed lock files

### Changed

- AWS provider constraint to `>= 5.0, < 7.0`

> Historical releases are documented in [GitHub Releases](https://github.com/pomo-studio/terraform-aws-ssr-storage/releases).
