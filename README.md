# DevOps Technical Assessment (AWS EKS)

This folder contains a complete starter solution for your assessment:

- Flask app (Python)
- Docker image build instructions
- Helm chart for Kubernetes manifests
- Optional Kafka consumer configuration
- Environment-specific values (dev/prod)
- Optional Terraform starter for EKS infrastructure
- GitOps-ready folder structure and Argo CD app manifest

## Start Here

Read **ASSIGNMENT_AWS_EKS_GUIDE.md** from top to bottom. It is written to teach you each step and the reasoning behind it.
Then configure pipeline access in **GITHUB_SECRETS_SETUP.md**.

For a high-level reviewer view, start with **docs/README.md**.

## GitOps-First Quick Start (No ClickOps)

1. Copy `scripts/config.env.example` to `scripts/config.env` and set your AWS values.
2. Run end-to-end automation:

```powershell
./scripts/run-all.ps1
```

3. Optional: install Argo CD and apply GitOps app manifest:

```powershell
./scripts/60-install-argocd-and-app.ps1
```

This script renders `gitops/argocd/application-prod.generated.yaml` from `gitops/argocd/application-prod.yaml.tpl` using `GIT_REPO_URL` from `scripts/config.env`.

4. Verify endpoint:

```powershell
./scripts/50-verify.ps1
```

5. Cleanup:

```powershell
./scripts/90-cleanup.ps1
```

## Pipeline-First Path (No Local AWS CLI Required for Deploy)

1. Set GitHub Secrets and Variables using `GITHUB_SECRETS_SETUP.md`.
2. Run GitHub Actions workflow `deploy-eks-gitops`.
3. Use `create_cluster=true` for first run, then `false`.
4. Select `deploy_environment` as `dev` or `prod`.

If CloudShell is unavailable, use local PowerShell bootstrap: `iam/create-oidc-role-local.ps1`.

## Folder Layout

- `app/` - Flask application source
- `helm/flask-kafka-app/` - Helm chart
- `gitops/argocd/` - GitOps manifest example
- `scripts/` - Scripted operational workflow (bootstrap, deploy, verify, cleanup)
- `infra/eksctl/` - Declarative EKS cluster configuration template
- `terraform/` - Optional IaC (bonus)
- `.github/workflows/deploy-eks-gitops.yaml` - Secure OIDC deployment workflow

## Outcome

By following the guide, you will be able to:

1. Create an EKS cluster
2. Build and push your Flask image to ECR
3. Deploy the app with Helm
4. Expose it publicly via AWS Load Balancer
5. Manage env vars and secrets safely
6. Explain the architecture during interview
