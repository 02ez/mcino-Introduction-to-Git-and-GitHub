# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enterprise-grade CI/CD workflows with GitHub Actions
- SLSA Level 3 supply chain security implementation
- Comprehensive security scanning (CodeQL, Trivy, Semgrep, Bandit, Safety)
- SBOM generation and artifact signing with Cosign
- Multi-environment deployment pipeline (staging, production)
- Container security scanning and hardened Dockerfile
- Comprehensive test infrastructure (unit, integration, BATS)
- Code quality tools (Black, flake8, isort, mypy)
- Dependabot configuration for automated dependency updates
- CODEOWNERS file for governance and required reviews
- Security policy with threat model and incident response
- Branch protection and review requirements
- Performance benchmarking and monitoring
- Blue-green deployment simulation
- Rollback procedures and failure handling

### Security
- OIDC authentication for all deployments (no long-lived secrets)
- Secret scanning with TruffleHog and GitHub native scanning
- Dependency vulnerability scanning with multiple tools
- Container image vulnerability scanning
- Static application security testing (SAST)
- Software composition analysis (SCA)
- Cryptographic signing of all build artifacts
- Provenance attestation for supply chain verification

### Infrastructure
- Multi-platform container builds (linux/amd64, linux/arm64)
- Health checks and monitoring endpoints
- Non-root container execution
- Hardened base images with security updates
- Caching and optimization for faster builds
- Concurrent workflow execution with proper safeguards
- Comprehensive logging and audit trails

## [1.0.0] - 2023-XX-XX

### Added
- Initial release with simple interest calculator (Shell)
- Compound interest calculator (Python)
- Basic README documentation
- Apache 2.0 license
- Code of Conduct
- Contributing guidelines
- GitHub issue templates

### Fixed
- Shell script executable permissions
- Python script input validation

### Changed
- Updated documentation for clarity
- Improved error handling in calculators

## [0.1.0] - Initial Development

### Added
- Basic Git and GitHub learning repository structure
- Simple financial calculation examples
- Educational content for version control learning