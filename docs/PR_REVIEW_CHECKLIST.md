# Pull Request Review Checklist

This checklist ensures all code changes meet enterprise security, quality, and compliance standards before merging.

## Pre-Review Requirements

### Automated Checks (Must Pass)
- [ ] All GitHub Actions workflows completed successfully
- [ ] CodeQL security analysis passed with no high/critical findings
- [ ] Dependency Review completed with no high-risk dependencies
- [ ] Trivy vulnerability scan passed (no critical/high vulnerabilities)
- [ ] Bandit Python security scan passed
- [ ] Secret scanning completed with no exposed secrets
- [ ] Container security scan passed (if applicable)
- [ ] SLSA provenance generated and verified
- [ ] SBOM generated and signed with Cosign

### Code Quality Gates
- [ ] Python code formatted with Black (if Python changes)
- [ ] Code linted with flake8 (no errors)
- [ ] Import sorting verified with isort
- [ ] Shell scripts validated with ShellCheck
- [ ] Test coverage maintains >80% threshold
- [ ] All unit tests passing
- [ ] Integration tests passing (>90% success rate)
- [ ] Performance benchmarks within acceptable limits

## Manual Review Checklist

### Security Review
- [ ] **No hardcoded secrets or credentials in code**
- [ ] **Input validation present for all user inputs**
- [ ] **Error handling doesn't expose sensitive information**
- [ ] **Proper authentication and authorization implemented**
- [ ] **SQL injection protection in place (if applicable)**
- [ ] **XSS protection implemented (if applicable)**
- [ ] **CSRF protection enabled (if applicable)**
- [ ] **Secure communication protocols used (HTTPS/TLS)**
- [ ] **File permissions set correctly**
- [ ] **Dependencies from trusted sources only**

### Code Quality Review
- [ ] **Code follows established patterns and conventions**
- [ ] **Functions are single-purpose and reasonably sized**
- [ ] **Complex logic is well-documented**
- [ ] **Error conditions are properly handled**
- [ ] **Resource cleanup is implemented (connections, files)**
- [ ] **Performance considerations addressed**
- [ ] **Code is readable and maintainable**
- [ ] **Unit tests cover new functionality**
- [ ] **Integration tests updated if needed**
- [ ] **Documentation updated for API changes**

### Architecture and Design
- [ ] **Changes align with existing architecture**
- [ ] **Design patterns used appropriately**
- [ ] **Separation of concerns maintained**
- [ ] **Interface contracts respected**
- [ ] **Backward compatibility preserved**
- [ ] **Database migrations are reversible (if applicable)**
- [ ] **Configuration changes documented**
- [ ] **Performance impact assessed**
- [ ] **Scalability considerations addressed**
- [ ] **Monitoring and logging added for new features**

### Compliance and Governance
- [ ] **CODEOWNERS approval obtained**
- [ ] **Security team approval for security-sensitive changes**
- [ ] **Change management process followed**
- [ ] **Regulatory requirements considered (SOC2, etc.)**
- [ ] **Data privacy requirements met (if applicable)**
- [ ] **License compatibility verified for new dependencies**
- [ ] **Documentation updated (README, API docs, runbooks)**
- [ ] **CHANGELOG.md updated with changes**
- [ ] **ADR created for significant architectural decisions**
- [ ] **Risk assessment completed for high-impact changes**

## Specialized Reviews

### Infrastructure Changes (Required for workflow/config changes)
- [ ] **GitHub Actions workflows use pinned versions**
- [ ] **Secrets management follows OIDC best practices**
- [ ] **Resource limits and timeouts configured**
- [ ] **Error handling and retry logic implemented**
- [ ] **Monitoring and alerting configured**
- [ ] **Rollback procedures documented**
- [ ] **Environment-specific configurations validated**
- [ ] **Security hardening applied (hardened runners, etc.)**

### Container/Docker Changes (Required for container updates)
- [ ] **Base images from trusted sources**
- [ ] **Security updates applied to base images**
- [ ] **Non-root user configured**
- [ ] **Minimal attack surface (minimal packages)**
- [ ] **Health checks implemented**
- [ ] **Resource limits set**
- [ ] **Multi-stage builds optimized**
- [ ] **Secrets not included in image layers**

### Dependency Changes (Required for dependency updates)
- [ ] **Dependencies scanned for vulnerabilities**
- [ ] **License compatibility verified**
- [ ] **Breaking changes reviewed and documented**
- [ ] **Security advisories checked**
- [ ] **Performance impact assessed**
- [ ] **Backward compatibility maintained**
- [ ] **Test coverage maintained**
- [ ] **Documentation updated for API changes**

## Risk Assessment

### Change Risk Level (Select One)
- [ ] **Low Risk**: Bug fixes, documentation updates, minor improvements
- [ ] **Medium Risk**: New features, dependency updates, configuration changes
- [ ] **High Risk**: Security changes, architectural modifications, breaking changes

### Additional Requirements by Risk Level

#### High Risk Changes (All Required)
- [ ] **Architectural review by senior engineer**
- [ ] **Security review by security team**
- [ ] **Performance testing completed**
- [ ] **Rollback plan documented and tested**
- [ ] **Stakeholder approval obtained**
- [ ] **Deployment plan reviewed**
- [ ] **Monitoring plan updated**
- [ ] **Incident response plan updated**

#### Medium Risk Changes (Select Applicable)
- [ ] **Peer review by experienced team member**
- [ ] **Additional testing in staging environment**
- [ ] **Performance impact assessed**
- [ ] **Documentation review**

## Deployment Considerations

### Environment Readiness
- [ ] **Staging deployment successful**
- [ ] **Integration tests passed in staging**
- [ ] **Performance tests passed in staging**
- [ ] **Security scans passed in staging**
- [ ] **Rollback tested in staging**
- [ ] **Monitoring verified in staging**

### Production Readiness
- [ ] **Feature flags configured (if applicable)**
- [ ] **Database migrations tested**
- [ ] **Configuration changes applied**
- [ ] **Monitoring and alerting configured**
- [ ] **Runbooks updated**
- [ ] **Team notified of deployment**

## Final Approval

### Required Approvals (All Must Be Obtained)
- [ ] **Code Owner Approval**: @02ez or designated code owner
- [ ] **Security Team Approval**: @github/security-team (for security-sensitive changes)
- [ ] **Platform Team Approval**: @github/platform-team (for infrastructure changes)
- [ ] **Domain Expert Approval**: Subject matter expert (for complex changes)

### Merge Criteria
- [ ] **All automated checks passing**
- [ ] **All required approvals obtained**
- [ ] **No outstanding review comments**
- [ ] **Documentation complete and accurate**
- [ ] **Deployment plan confirmed**
- [ ] **Risk assessment complete**
- [ ] **Compliance requirements met**

## Post-Merge Requirements

### Immediate Actions (Within 24 hours)
- [ ] **Monitor deployment metrics**
- [ ] **Verify functionality in production**
- [ ] **Check error rates and performance**
- [ ] **Confirm security scans pass**
- [ ] **Update project boards/tickets**

### Follow-up Actions (Within 1 week)
- [ ] **Performance monitoring review**
- [ ] **Security metrics review**
- [ ] **User feedback collection**
- [ ] **Documentation feedback incorporation**
- [ ] **Process improvement suggestions**

## Emergency Override

In case of security incidents or critical production issues, this checklist may be abbreviated with explicit approval from:
- **Security Team Lead** (for security emergencies)
- **Engineering Manager** (for critical production issues)
- **VP of Engineering** (for business-critical emergencies)

All emergency overrides must be documented with:
- [ ] **Reason for override**
- [ ] **Risk assessment**
- [ ] **Mitigation plan**
- [ ] **Follow-up remediation plan**
- [ ] **Approval from authorized personnel**

---

**Reviewers**: By approving this PR, you confirm that you have reviewed all applicable items in this checklist and that the changes meet the required standards.

**Author**: By submitting this PR, you confirm that you have addressed all applicable items in this checklist and that the changes are ready for review.

---

**Last Updated**: Current Date  
**Version**: 1.0  
**Owner**: Engineering Standards Committee