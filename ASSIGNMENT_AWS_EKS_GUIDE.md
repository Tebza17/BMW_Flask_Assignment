# AWS EKS DevOps Assessment Guide (Teach-by-Doing)

This guide helps you implement the assignment end-to-end on AWS using EKS, Helm, and GitOps practices.

---

## 1. What you are building

You will deploy a small Flask API to Kubernetes on AWS EKS.

You will use:

- Docker for packaging
- Amazon ECR for image registry
- EKS for Kubernetes cluster
- Helm for Kubernetes manifests
- Kubernetes `Secret` and `ConfigMap` for configuration
- Optional: Kafka consumer settings
- Optional bonus: Terraform for infra

Think of this as three layers:

1. Application layer: Flask app code
2. Platform layer: Kubernetes objects (Deployment, Service, etc.)
3. Infrastructure layer: AWS networking and EKS cluster

---

## 2. Accounts and setup checklist

Create these accounts/access first.

## 2.1 Required accounts

1. AWS account (free tier is fine to start)
2. GitHub account (for repository link sharing)

## 2.2 Install locally (Windows)

1. Docker Desktop
2. AWS CLI v2
3. kubectl
4. eksctl
5. Helm 3
6. Git
7. Python 3.11+ (optional, for local app testing)
8. Terraform (optional bonus)

If AWS CLI is not installed yet, you can still deploy through GitHub Actions using `GITHUB_SECRETS_SETUP.md`.

## 2.3 AWS permissions you need

Use an IAM user (or role) with permission for:

- EKS
- EC2 (for VPC, subnets, security groups)
- IAM (for EKS roles)
- CloudFormation (eksctl uses it)
- ECR
- Elastic Load Balancing

For assessment work, many candidates use `AdministratorAccess` in a sandbox account. For real production, use least-privilege roles.

## 2.4 Configure CLI auth

```bash
aws configure
# set Access Key ID, Secret Access Key, region (for example us-east-1), output json
```

Verify:

```bash
aws sts get-caller-identity
```

## 2.5 GitOps, not ClickOps (how to earn points)

Use scripts and declarative files as your default path:

1. `scripts/config.env` stores non-secret deployment parameters
2. `infra/eksctl/cluster-config.yaml.tpl` defines cluster shape in code
3. `scripts/*.ps1` runs repeatable CLI automation
4. Helm values and templates are versioned in Git
5. Argo CD manifest points to your repo for continuous reconciliation
6. GitHub Secrets/Variables keep credentials and runtime config out of code

Avoid AWS console manual creation during the demo unless you are explicitly explaining fallback steps.

---

## 3. Architecture you will explain in interview

Request flow:

1. Browser calls AWS Load Balancer URL
2. Load balancer forwards to Kubernetes Service
3. Service forwards to Flask Pods managed by Deployment
4. Pod reads config from ConfigMap and Secret
5. Optional: Pod also consumes Kafka messages

Reliability features included:

- 2+ replicas
- readiness and liveness probes
- rolling updates
- resource requests/limits
- PodDisruptionBudget
- optional HorizontalPodAutoscaler

---

## 4. Step-by-step execution

## Fastest secure path (recommended)

1. Configure secrets and variables in `GITHUB_SECRETS_SETUP.md`
2. Trigger workflow `.github/workflows/deploy-eks-gitops.yaml`
3. Use `create_cluster=true` on first run
4. Use `create_cluster=false` for later updates

This path is ideal when your local machine is missing AWS CLI.

Preferred execution path for this assignment:

```powershell
Copy-Item scripts/config.env.example scripts/config.env
# edit scripts/config.env with your values
./scripts/run-all.ps1
./scripts/60-install-argocd-and-app.ps1
./scripts/50-verify.ps1
```

Manual commands remain below for learning and troubleshooting.

## Step 1: Create git repository

```bash
git init
git add .
git commit -m "chore: initial assessment scaffold"
```

Create a GitHub repo and push:

```bash
git remote add origin https://github.com/Tebza17/BMW_Flask_Assignment.git
git branch -M main
git push -u origin main
```

This satisfies the requirement to share a viewable link.

Also commit automation scripts and infra templates; this demonstrates GitOps maturity.

## Step 2: Create ECR repository

```bash
aws ecr create-repository --repository-name flask-kafka-app
```

Get account ID:

```bash
aws sts get-caller-identity --query Account --output text
```

Set variables (PowerShell):

```powershell
$AWS_REGION="us-east-1"
$ACCOUNT_ID="<your-account-id>"
$ECR_REPO="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/flask-kafka-app"
```

Login Docker to ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

## Step 3: Build and push app image

From `app/` directory:

```bash
docker build -t flask-kafka-app:0.1.0 .
docker tag flask-kafka-app:0.1.0 <ecr-repo>:0.1.0
docker push <ecr-repo>:0.1.0
```

## Step 4: Create EKS cluster

Use `eksctl` (fast for assessment):

```bash
eksctl create cluster --name devops-assessment-eks --region us-east-1 --nodes 2 --node-type t3.medium --managed
```

GitOps-friendly alternative used in this repo:

```powershell
./scripts/30-create-cluster.ps1
```

This generates `infra/eksctl/cluster-config.generated.yaml` from `infra/eksctl/cluster-config.yaml.tpl` so cluster shape stays codified.

Update kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-1 --name devops-assessment-eks
kubectl get nodes
```

## Step 5: Deploy with Helm

From `helm/flask-kafka-app`:

```bash
helm lint .
helm upgrade --install flask-kafka-app . -n assessment --create-namespace -f values-dev.yaml
```

Scripted alternative used in this repo:

```powershell
./scripts/40-deploy-helm.ps1
```

Check deployment:

```bash
kubectl get all -n assessment
kubectl get svc -n assessment
kubectl get pods -n assessment
```

## Step 6: Access app externally

Service type is `LoadBalancer`, so AWS provisions an ELB.

```bash
kubectl get svc -n assessment
```

Copy `EXTERNAL-IP` or hostname and open in browser:

- `http://<elb-hostname>/health`
- `http://<elb-hostname>/`

## Step 7: Configure environment variables and secrets

In Helm values:

- Non-sensitive config in `config` section
- Sensitive values in `secrets` section

Never commit real secrets. Use placeholders in git, inject actual values through CI/CD or secret manager.

## Step 8: Optional Kafka configuration

Set:

- `KAFKA_ENABLED=true`
- `KAFKA_BOOTSTRAP_SERVERS`
- `KAFKA_TOPIC`
- `KAFKA_GROUP_ID`

If credentials are needed, place them in secrets.

---

## 5. GitOps approach (important for assessment)

GitOps means Git is the source of truth.

Recommended flow:

1. Change Helm values/chart in a branch
2. Open Pull Request
3. Review and merge
4. Argo CD (or Flux) auto-syncs cluster from repository

This repo includes an Argo CD Application example in `gitops/argocd/application-prod.yaml`.
Set its `repoURL` to `https://github.com/Tebza17/BMW_Flask_Assignment.git`.

Script-first approach in this repo:

1. Set `GIT_REPO_URL` in `scripts/config.env`
2. Render Application manifest from template with `./scripts/61-render-argocd-app.ps1`
3. Install/apply with `./scripts/60-install-argocd-and-app.ps1`

Script to install Argo CD and apply app manifest:

```powershell
./scripts/60-install-argocd-and-app.ps1
```

Even if you deploy manually in interview prep, explain how GitOps controller would continuously reconcile desired state from Git.

---

## 6. Different configs per cluster (dev/prod)

Use separate values files:

- `values-dev.yaml`
- `values-prod.yaml`

Deploy dev:

```bash
helm upgrade --install flask-kafka-app . -n assessment-dev --create-namespace -f values-dev.yaml
```

Deploy prod:

```bash
helm upgrade --install flask-kafka-app . -n assessment-prod --create-namespace -f values-prod.yaml
```

---

## 7. Bonus: Terraform (infrastructure as code)

Terraform starter is in `terraform/`.

High-level sequence:

1. `terraform init`
2. `terraform plan`
3. `terraform apply`
4. Use generated cluster outputs for kubectl/helm deployment

In interview, emphasize why Terraform helps:

- repeatable environments
- versioned infra changes
- peer-reviewable infrastructure

---

## 8. Reliability and production-critical points to mention

1. Probes prevent bad pods from receiving traffic
2. Resource requests protect scheduling stability
3. Limits reduce noisy-neighbor risk
4. PDB helps during node maintenance
5. Multiple replicas reduce single-point failure
6. Rolling updates avoid downtime
7. Avoid hardcoded secrets
8. Add monitoring/logging in real environments (CloudWatch, Prometheus, Grafana)

---

## 9. Demo checklist (before interview)

1. Show repository structure
2. Explain Helm templates quickly
3. Show running pods and service URL
4. Hit `/health` endpoint live
5. Show env config and secret strategy
6. Explain GitOps workflow
7. Mention Terraform bonus and how you would apply it

---

## 10. Cleanup (avoid AWS costs)

If created with `eksctl`:

```bash
eksctl delete cluster --name devops-assessment-eks --region us-east-1
```

Delete ECR repo if needed:

```bash
aws ecr delete-repository --repository-name flask-kafka-app --force
```

Scripted cleanup:

```powershell
./scripts/90-cleanup.ps1
```

---

## 11. What to submit

1. GitHub repository link
	- `https://github.com/Tebza17/BMW_Flask_Assignment`
2. README/guide (this file)
3. Helm chart + app code
4. Optional Terraform folder
5. Short notes on tradeoffs and next improvements

You now have a complete assessment-ready base in this folder. Next, follow the command steps and replace placeholders with your AWS values.
