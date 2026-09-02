# GitOps and Delivery Flow

## Delivery Principles

- Favor declarative configuration over ad hoc cluster changes
- Keep environment values version-controlled
- Drive deployments from pipeline automation

## Pipeline Stages (Conceptual)

1. Source checkout and dependency setup
2. Validation and build checks
3. OIDC-based AWS role assumption
4. Image build and push
5. Helm deployment to target namespace
6. Verification checks

## Why This Matters

- Auditable change history
- Repeatable releases
- Reduced credential risk through short-lived tokens

## Where To Go Next

- [Security and Access Model](04-security-access-model.md)
- [GitHub Secrets and Variables Setup](../GITHUB_SECRETS_SETUP.md)
