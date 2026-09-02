# GitHub Secrets and Variables Setup (Pipeline Access)

This project supports secure deployment from GitHub Actions without storing AWS credentials in repository files.

Before starting, review:

1. `SETUP_INPUTS_CHECKLIST.md`
2. `iam/github-oidc-trust-policy.json`
3. `iam/github-actions-eks-deployer-permissions.json`

## Recommended security model: OIDC (best practice)

Use short-lived credentials with a role trust relationship between AWS IAM and GitHub Actions.

## Auto-create role in AWS CloudShell (no local AWS CLI required)

Run these commands in AWS CloudShell:

```bash
git clone https://github.com/Tebza17/BMW_Flask_Assignment.git
cd BMW_Flask_Assignment
chmod +x iam/create-oidc-role-cloudshell.sh
./iam/create-oidc-role-cloudshell.sh us-east-1 Tebza17 BMW_Flask_Assignment main github-actions-eks-deployer
```

Output includes the IAM Role ARN. Copy it to GitHub Secret `AWS_ROLE_TO_ASSUME`.

## OIDC trust troubleshooting (important)

Some GitHub accounts now emit a `sub` claim with numeric IDs in the owner and repo segments, for example:

`repo:Tebza17@28624729/BMW_Flask_Assignment@1354820876:ref:refs/heads/main`

This repository's IAM templates already allow both formats:

1. `repo:<owner>/<repo>:ref:refs/heads/<branch>`
2. `repo:<owner>@*/<repo>@*:ref:refs/heads/<branch>`

If your role was created before this update, re-run the CloudShell setup command to refresh trust policy conditions:

```bash
cd BMW_Flask_Assignment
./iam/create-oidc-role-cloudshell.sh eu-west-1 Tebza17 BMW_Flask_Assignment main github-actions-eks-deployer
```

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
8. `KAFKA_ENABLED` (example: `true`)
9. `KAFKA_BOOTSTRAP_SERVERS` (example: `kafka.kafka.svc.cluster.local:9092`)
10. `KAFKA_TOPIC` (example: `events`)
11. `KAFKA_GROUP_ID` (example: `flask-kafka-app-prod`)

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
gh variable set KAFKA_ENABLED --body "true"
gh variable set KAFKA_BOOTSTRAP_SERVERS --body "kafka.kafka.svc.cluster.local:9092"
gh variable set KAFKA_TOPIC --body "events"
gh variable set KAFKA_GROUP_ID --body "flask-kafka-app-prod"
```
