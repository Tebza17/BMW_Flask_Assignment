# Platform Overview

## Goal

Provide a GitOps-oriented deployment path for a Flask service running on AWS EKS, with optional Kafka messaging support and secure CI/CD authentication.

## Core Components

- Application: Python Flask service
- Container: Docker image stored in Amazon ECR
- Orchestration: Amazon EKS
- Packaging and release: Helm chart
- Delivery automation: GitHub Actions
- Identity and auth: GitHub OIDC to AWS IAM role assumption

## Environments

- Supports environment-based values through Helm values files
- Enables first-run cluster bootstrap and subsequent deployment-only runs

## Where To Go Next

- [Architecture Summary](02-architecture-summary.md)
- [Assessment Walkthrough](../ASSIGNMENT_AWS_EKS_GUIDE.md)
