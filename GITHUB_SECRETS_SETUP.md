# GitHub Secrets and Variables Setup (Pipeline Access)

This project supports secure deployment from GitHub Actions without storing AWS credentials in repository files.

## Recommended security model: OIDC (best practice)

Use short-lived credentials with a role trust relationship between AWS IAM and GitHub Actions.

## Repository Secrets to create

1. `AWS_ROLE_TO_ASSUME`
   - IAM Role ARN trusted by GitHub OIDC
   - Example: `arn:aws:iam::123456789012:role/github-actions-eks-deployer`
2. `KAFKA_USERNAME` (optional)
3. `KAFKA_PASSWORD` (optional)

## Repository Variables to create

1. `AWS_REGION` (example: `us-east-1`)
2. `EKS_CLUSTER_NAME` (example: `devops-assessment-eks`)
3. `ECR_REPOSITORY_NAME` (example: `flask-kafka-app`)
4. `K8S_NAMESPACE` (example: `assessment`)
5. `HELM_RELEASE_NAME` (example: `flask-kafka-app`)
6. `NODE_TYPE` (example: `t3.medium`)
7. `NODE_COUNT` (example: `2`)

## Why this earns points

1. No long-lived AWS keys in repo
2. Principle of least privilege via IAM role
3. Fully auditable deployment via workflow runs
4. Reproducible env values via repo variables

## Run the deployment pipeline

1. Open Actions tab
2. Run workflow: `deploy-eks-gitops`
3. Choose:
   - `deploy_environment`: `dev` or `prod`
   - `create_cluster`: `true` for first run, then `false`

## Optional: set secrets/variables via GitHub CLI (scriptable)

If you install `gh`, you can avoid UI clicks:

```bash
gh secret set AWS_ROLE_TO_ASSUME --body "arn:aws:iam::<account-id>:role/github-actions-eks-deployer"
gh variable set AWS_REGION --body "us-east-1"
gh variable set EKS_CLUSTER_NAME --body "devops-assessment-eks"
gh variable set ECR_REPOSITORY_NAME --body "flask-kafka-app"
gh variable set K8S_NAMESPACE --body "assessment"
gh variable set HELM_RELEASE_NAME --body "flask-kafka-app"
gh variable set NODE_TYPE --body "t3.medium"
gh variable set NODE_COUNT --body "2"
```
