# Operations Runbook

## Typical Execution Paths

1. Pipeline-first path
2. Script-first local path
3. Cleanup path

## Pipeline-First

- Configure secrets and variables
- Run deploy workflow with appropriate inputs
- Verify deployment and endpoint health

## Script-First

- Use provided PowerShell scripts for bootstrap, deploy, verify, and cleanup
- Optionally install and validate Kafka inside cluster

## Operational Checks

- Pod readiness and liveness
- Service endpoint availability
- Deployment rollout status
- OIDC role assumption status in workflow logs

## Where To Go Next

- [Main Project Guide](../README.md)
- [Assessment Walkthrough](../ASSIGNMENT_AWS_EKS_GUIDE.md)
