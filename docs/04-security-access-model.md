# Security and Access Model

## Authentication Approach

The pipeline uses GitHub OIDC to request short-lived AWS credentials by assuming an IAM role.

## Security Controls

- No long-lived AWS keys stored in repository
- IAM trust policy restricts allowed audience and token claims
- Repository secrets and variables separate sensitive vs non-sensitive data

## Current Focus Area

OIDC trust policy alignment is required for account-specific token subject formats. The trust policy templates in this repository include support for both classic and ID-augmented subject patterns.

## Where To Go Next

- [GitHub Secrets and Variables Setup](../GITHUB_SECRETS_SETUP.md)
- [Setup Inputs Checklist](../SETUP_INPUTS_CHECKLIST.md)
