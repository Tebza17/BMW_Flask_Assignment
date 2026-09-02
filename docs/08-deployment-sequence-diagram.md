# Deployment Sequence Diagram

This sequence diagram focuses only on the deployment path from trigger to running workload.

```mermaid
sequenceDiagram
  autonumber
  participant Dev as Developer
  participant GH as GitHub Repo
  participant GHA as GitHub Actions
  participant OIDC as GitHub OIDC
  participant IAM as AWS IAM STS
  participant EKS as Amazon EKS
  participant ECR as Amazon ECR
  participant HELM as Helm CLI
  participant K8S as Kubernetes API
  participant APP as Flask Pods

  Dev->>GH: Push code or trigger workflow_dispatch
  GH->>GHA: Start deploy-eks-gitops workflow

  GHA->>OIDC: Request id token (aud sts.amazonaws.com)
  OIDC-->>GHA: JWT with repository claims
  GHA->>IAM: AssumeRoleWithWebIdentity
  IAM-->>GHA: Temporary AWS credentials

  GHA->>EKS: Check cluster status and reconcile if needed
  GHA->>EKS: Update kubeconfig

  GHA->>ECR: Ensure repository exists
  GHA->>ECR: Login and push image tag

  GHA->>HELM: helm upgrade --install
  HELM->>K8S: Apply Deployment, Service, ConfigMap, Secret
  K8S->>APP: Schedule pods on nodegroup
  APP-->>K8S: Readiness and liveness probes

  GHA->>K8S: Wait for rollout status
  K8S-->>GHA: Deployment available
  GHA-->>Dev: Workflow succeeded
```

## Key Failure Points Covered in Pipeline

- OIDC role assumption failure
- Missing or stale EKS/CloudFormation resources
- Nodegroup with zero registered nodes
- Rollout timeout with pod-level diagnostics
