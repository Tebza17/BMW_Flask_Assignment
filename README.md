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

## Folder Layout

- `app/` - Flask application source
- `helm/flask-kafka-app/` - Helm chart
- `gitops/argocd/` - GitOps manifest example
- `terraform/` - Optional IaC (bonus)

## Outcome

By following the guide, you will be able to:

1. Create an EKS cluster
2. Build and push your Flask image to ECR
3. Deploy the app with Helm
4. Expose it publicly via AWS Load Balancer
5. Manage env vars and secrets safely
6. Explain the architecture during interview
