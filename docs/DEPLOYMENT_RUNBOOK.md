# Deployment Runbook

## Overview

This runbook provides step-by-step procedures for deploying the financial calculators application across different environments with proper safety controls and rollback procedures.

## Pre-Deployment Checklist

### Required Approvals
- [ ] Security team approval for vulnerability scans
- [ ] Code owner approval from CODEOWNERS
- [ ] Infrastructure team approval for deployment
- [ ] Business stakeholder sign-off for production

### Technical Prerequisites
- [ ] All CI/CD workflows passing (build-test, security-scan, supply-chain)
- [ ] SLSA Level 3 provenance generated and verified
- [ ] SBOM created and signed with Cosign
- [ ] Container security scan completed with no critical vulnerabilities
- [ ] Integration tests passing with >90% success rate
- [ ] Performance benchmarks within acceptable thresholds

### Environment Readiness
- [ ] Target environment healthy and accessible
- [ ] Required secrets and configurations updated
- [ ] Monitoring and alerting systems operational
- [ ] Rollback version identified and tested

## Deployment Procedures

### Staging Deployment

#### 1. Pre-Deployment Verification
```bash
# Verify workflow status
gh run list --workflow=build-test.yaml --limit=1
gh run list --workflow=security-scan.yaml --limit=1
gh run list --workflow=supply-chain.yaml --limit=1

# Check latest commit status
gh status

# Verify container image
docker pull ghcr.io/02ez/mcino-introduction-to-git-and-github:latest
docker inspect ghcr.io/02ez/mcino-introduction-to-git-and-github:latest
```

#### 2. Trigger Staging Deployment
```bash
# Manual deployment trigger
gh workflow run deploy.yaml -f environment=staging

# Monitor deployment progress
gh run watch
```

#### 3. Post-Deployment Verification
```bash
# Health check
curl -f https://staging.example.com/health || echo "Health check failed"

# Functional tests
docker run --rm ghcr.io/02ez/mcino-introduction-to-git-and-github:latest \
  python3 -c "
import compound_interest
result = compound_interest.compound_interest(1000, 2, 5)
assert abs(result - 1102.5) < 0.01
print('✅ Staging verification passed')
"

# Monitor logs for errors
kubectl logs -n staging -l app=financial-calculators --tail=100
```

### Production Deployment

#### 1. Pre-Production Checks
```bash
# Verify staging deployment success
gh run list --workflow=deploy.yaml --limit=5

# Check staging health metrics
curl -s https://staging.example.com/metrics | grep -E "(cpu|memory|errors)"

# Review security scan results
gh api repos/02ez/mcino-introduction-to-git-and-github/security-advisories
```

#### 2. Production Deployment Process
```bash
# Create production deployment
gh workflow run deploy.yaml -f environment=production

# This will trigger manual approval - check issues
gh issue list --label="deployment-approval"

# After approval, monitor deployment
gh run watch --exit-status
```

#### 3. Blue-Green Deployment Verification
```bash
# Check blue environment (current production)
curl -f https://production.example.com/health

# Verify green environment (new version)
curl -f https://green.production.example.com/health

# Traffic split verification
curl -s https://production.example.com/version | jq '.version'

# Monitor error rates during transition
kubectl logs -n production -l app=financial-calculators,version=green --tail=50
```

#### 4. Production Validation
```bash
# End-to-end functional test
docker run --rm ghcr.io/02ez/mcino-introduction-to-git-and-github:latest \
  bash -c "
echo '1000
2
5' | python3 compound_interest.py | grep -q '1102.50' && \
echo '✅ Production functional test passed' || \
echo '❌ Production functional test failed'
"

# Performance verification
ab -n 100 -c 10 https://production.example.com/api/compound-interest

# Security validation
nmap -p 443 production.example.com
```

## Rollback Procedures

### Automated Rollback Triggers
- Health check failures for >5 minutes
- Error rate >5% for >2 minutes
- Response time >2 seconds for >3 minutes
- Security alert with severity HIGH or CRITICAL

### Manual Rollback Process

#### 1. Immediate Response (0-5 minutes)
```bash
# Stop traffic to new version
kubectl patch service financial-calculators -p '{"spec":{"selector":{"version":"blue"}}}'

# Scale down new version
kubectl scale deployment financial-calculators-green --replicas=0

# Verify rollback
curl -s https://production.example.com/version | jq '.version'
```

#### 2. Investigation Phase (5-30 minutes)
```bash
# Collect logs from failed deployment
kubectl logs -n production -l app=financial-calculators,version=green > rollback-logs.txt

# Capture metrics during failure
curl -s https://production.example.com/metrics > rollback-metrics.json

# Check security events
gh api repos/02ez/mcino-introduction-to-git-and-github/security-advisories
```

#### 3. Cleanup and Documentation (30-60 minutes)
```bash
# Remove failed deployment
kubectl delete deployment financial-calculators-green

# Update deployment status
gh issue create --title "Production Rollback - $(date)" \
  --body "Rollback completed due to [REASON]. Investigation required."

# Notify stakeholders
echo "Production rollback completed at $(date)" | \
  mail -s "ALERT: Production Rollback" ops-team@company.com
```

## Monitoring and Alerting

### Key Metrics to Monitor
- **Availability**: >99.9% uptime
- **Response Time**: <500ms p95
- **Error Rate**: <1% 
- **CPU Usage**: <70%
- **Memory Usage**: <80%
- **Security Events**: 0 critical/high

### Alert Definitions
```yaml
alerts:
  - name: HighErrorRate
    condition: error_rate > 5%
    duration: 2m
    action: auto-rollback
    
  - name: HighLatency
    condition: p95_latency > 2s
    duration: 3m
    action: auto-rollback
    
  - name: SecurityVulnerability
    condition: security_severity in [HIGH, CRITICAL]
    duration: 0s
    action: immediate-rollback
```

### Dashboard URLs
- **Production Health**: https://monitoring.company.com/financial-calculators-prod
- **Security Dashboard**: https://security.company.com/repos/02ez/mcino-introduction-to-git-and-github
- **Performance Metrics**: https://apm.company.com/financial-calculators

## Emergency Procedures

### Incident Response
1. **Acknowledge**: Respond to alerts within 5 minutes
2. **Assess**: Determine impact and severity within 10 minutes
3. **Mitigate**: Execute rollback if needed within 15 minutes
4. **Communicate**: Update stakeholders within 30 minutes
5. **Resolve**: Fix root cause within 24 hours
6. **Review**: Post-incident review within 48 hours

### Emergency Contacts
- **On-Call Engineer**: +1-555-0123 (primary), +1-555-0124 (backup)
- **Security Team**: security@company.com
- **Infrastructure Team**: infrastructure@company.com
- **Business Stakeholder**: product-owner@company.com

### Escalation Matrix
| Time | Action | Contact |
|------|---------|---------|
| 0-15 min | Initial response | On-call engineer |
| 15-30 min | Escalate to team lead | Team lead |
| 30-60 min | Escalate to management | Engineering manager |
| 60+ min | Executive notification | VP Engineering |

## Compliance and Audit

### Required Documentation
- [ ] Deployment approval records
- [ ] Security scan results
- [ ] Change management tickets
- [ ] Post-deployment verification results
- [ ] Rollback procedures tested

### Audit Trail
All deployment activities are automatically logged:
- GitHub Actions workflow runs
- Container registry push/pull events
- Kubernetes deployment events
- Security scan results
- SLSA provenance records

### Retention Policies
- **Deployment Logs**: 1 year
- **Security Scan Results**: 2 years
- **SBOM and Provenance**: 3 years
- **Audit Records**: 7 years

## Troubleshooting Guide

### Common Issues

#### Deployment Fails at Security Scan
```bash
# Check specific scan failures
gh run view --log | grep -E "(CRITICAL|HIGH)"

# Review vulnerability details
gh security advisories list

# Solution: Fix vulnerabilities or create waivers
```

#### Container Health Check Failures
```bash
# Check container logs
kubectl logs -n production -l app=financial-calculators

# Verify health endpoint
kubectl exec -it deployment/financial-calculators -- curl localhost:8080/health

# Solution: Fix application or health check configuration
```

#### SLSA Verification Failures
```bash
# Check provenance generation
gh run view --log | grep "provenance"

# Verify signing
cosign verify ghcr.io/02ez/mcino-introduction-to-git-and-github:latest

# Solution: Regenerate and re-sign artifacts
```

### Performance Issues
```bash
# Check resource usage
kubectl top pods -n production

# Analyze slow queries
kubectl logs -n production -l app=financial-calculators | grep "slow"

# Solution: Scale up or optimize code
```

---

**Last Updated**: Current Date  
**Owner**: Platform Engineering Team  
**Review Schedule**: Monthly