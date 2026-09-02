# End-to-End Architecture Diagram

This diagram shows the full application and infrastructure flow, from source control to runtime traffic.

```mermaid
flowchart LR
  Dev[Developer]
  GH[GitHub Repository]
  GHA[GitHub Actions\nCI and Deploy Workflow]
  OIDC[GitHub OIDC Token Service]
  IAM[AWS IAM Role\ngithub-actions-eks-deployer]
  ECR[Amazon ECR\nflask-kafka-app]
  CFN[AWS CloudFormation\neksctl stacks]
  EKS[AWS EKS Control Plane\ndevops-assessment-eks]
  NG[Managed Node Group\nprimary-ng EC2 nodes]
  K8S[Kubernetes Namespace\nassessment]
  HELM[Helm Release\nflask-kafka-app]
  APP[Flask App Pods\nDeployment and Service]
  NLB[LoadBalancer Service\nExternal Endpoint]
  KAFKA[Kafka Broker\nin-cluster optional]
  USER[End User or Tester]

  Dev -->|commit and push| GH
  GH -->|workflow_dispatch or push| GHA
  GHA -->|request id-token| OIDC
  OIDC -->|jwt claims| GHA
  GHA -->|AssumeRoleWithWebIdentity| IAM
  IAM -->|temporary aws credentials| GHA

  GHA -->|create or reconcile cluster| CFN
  CFN -->|provisions and updates| EKS
  EKS -->|attaches compute| NG
  NG -->|joins cluster| EKS

  GHA -->|build and push image| ECR
  GHA -->|aws eks update-kubeconfig| EKS
  GHA -->|helm upgrade install| HELM
  HELM -->|creates workloads| K8S
  K8S --> APP
  APP -->|pull image| ECR

  APP <--> |publish and consume events| KAFKA
  APP --> NLB
  USER -->|http and health checks| NLB

  subgraph Repo_Assets[Repository Assets]
    CHART[helm/flask-kafka-app]
    EKSCTL[infra/eksctl/cluster-config template]
    SCRIPTS[scripts and docs]
  end

  GH --> CHART
  GH --> EKSCTL
  GH --> SCRIPTS
  CHART --> HELM
  EKSCTL --> CFN
```

## Notes

- Authentication is keyless through OIDC and IAM role assumption.
- Container images are stored in ECR and deployed into EKS using Helm.
- Kafka is optional and controlled by environment configuration.
- The workflow supports both first-time cluster creation and repeat deployments.
