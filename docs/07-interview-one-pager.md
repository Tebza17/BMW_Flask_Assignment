# Interview One-Pager

## Problem Statement

Deliver a production-like, GitOps-oriented deployment pipeline for a Flask service on AWS EKS with secure CI/CD authentication and optional Kafka messaging.

## What Was Built

- Flask microservice with health and Kafka endpoints
- Containerized deployment with Docker and Amazon ECR
- Kubernetes deployment to Amazon EKS via Helm
- GitHub Actions pipeline for build, push, and deploy
- OIDC-based IAM role assumption (no static AWS keys)

## Architecture Summary

1. Code is committed to GitHub.
2. GitHub Actions authenticates to AWS using OIDC.
3. The pipeline builds and pushes an image to ECR.
4. Helm deploys the app into EKS.
5. Service exposes `/health` for readiness checks.

## Security Highlights

- Short-lived AWS credentials through OIDC
- IAM trust restricted to repository and branch claims
- Secrets and non-secret variables separated in GitHub settings

## Reliability and Operations

- Idempotent cluster reconciliation logic in deployment workflow
- Nodegroup and stack diagnostics for failure analysis
- Kubernetes rollout diagnostics (events, pod describe, logs)

## Demo Talking Points

- Why GitOps over ClickOps: repeatable, auditable changes
- Why OIDC over static keys: lower credential risk
- How rollback works: Helm release revisions
- How troubleshooting works: workflow diagnostics plus Kubernetes events

## Main Docs

- [Project Wiki Home](README.md)
- [End-to-End Architecture Diagram](06-architecture-diagram.md)
- [Deployment Sequence Diagram](08-deployment-sequence-diagram.md)
- [Detailed Project Guide](../README.md)
