# Setup Inputs Checklist (What to collect and where to store it)

Use this checklist to gather all required values for secure GitOps deployment.

## Rule of thumb

1. Secrets go to GitHub Secrets.
2. Non-sensitive config goes to GitHub Variables.
3. IAM trust and permissions stay in AWS IAM.
4. Do not commit credentials into repo files.

## A) Collect from AWS account

1. AWS Account ID
- Example format: 123456789012
- Where to store:
  - GitHub Variable: not required (workflow auto-resolves), optional
  - Local scripts: optional in scripts/config.env

2. AWS Region
- Example: us-east-1
- Where to store:
  - GitHub Variable: AWS_REGION
  - Local scripts/config.env: AWS_REGION

3. EKS Cluster Name
- Example: devops-assessment-eks
- Where to store:
  - GitHub Variable: EKS_CLUSTER_NAME
  - Local scripts/config.env: CLUSTER_NAME

4. ECR Repository Name
- Example: flask-kafka-app
- Where to store:
  - GitHub Variable: ECR_REPOSITORY_NAME
  - Local scripts/config.env: ECR_REPOSITORY_NAME

5. Kubernetes Namespace
- Example: assessment
- Where to store:
  - GitHub Variable: K8S_NAMESPACE
  - Local scripts/config.env: K8S_NAMESPACE

6. Helm Release Name
- Example: flask-kafka-app
- Where to store:
  - GitHub Variable: HELM_RELEASE_NAME
  - Local scripts/config.env: HELM_RELEASE_NAME

7. Node Group Instance Type
- Example: t3.medium
- Where to store:
  - GitHub Variable: NODE_TYPE
  - Local scripts/config.env: NODE_TYPE

8. Node Group Desired Count
- Example: 2
- Where to store:
  - GitHub Variable: NODE_COUNT
  - Local scripts/config.env: NODE_COUNT

## B) Collect for GitHub OIDC role (critical)

1. GitHub owner
- Your account or org name
- Example: Tebza17
- Used in IAM trust policy condition

2. GitHub repo name
- Example: BMW_Flask_Assignment
- Used in IAM trust policy condition

3. Branch restriction
- Example: main
- Used in IAM trust policy condition

4. IAM Role ARN for GitHub Actions
- Example: arn:aws:iam::123456789012:role/github-actions-eks-deployer
- Where to store:
  - GitHub Secret: AWS_ROLE_TO_ASSUME

## C) Optional Kafka inputs

1. Kafka username
- Where to store:
  - GitHub Secret: KAFKA_USERNAME

2. Kafka password
- Where to store:
  - GitHub Secret: KAFKA_PASSWORD

3. Kafka bootstrap servers, topic, group ID
- Where to store:
  - Helm values files if non-sensitive:
    - helm/flask-kafka-app/values-dev.yaml
    - helm/flask-kafka-app/values-prod.yaml

## D) GitHub repository variables to create

Create these under GitHub repo Settings -> Secrets and variables -> Actions -> Variables.

1. AWS_REGION
2. EKS_CLUSTER_NAME
3. ECR_REPOSITORY_NAME
4. K8S_NAMESPACE
5. HELM_RELEASE_NAME
6. NODE_TYPE
7. NODE_COUNT

## E) GitHub repository secrets to create

Create these under GitHub repo Settings -> Secrets and variables -> Actions -> Secrets.

1. AWS_ROLE_TO_ASSUME
2. KAFKA_USERNAME (optional)
3. KAFKA_PASSWORD (optional)

## F) Where to keep IAM JSON policies

Keep policy JSON in repo for review and audit (good GitOps practice):

1. iam/github-oidc-trust-policy.json
2. iam/github-actions-eks-deployer-permissions.json

Important:
- These policy JSON files should contain no private keys.
- They are safe to commit.

## G) What never goes in git

1. AWS access keys
2. Kafka passwords if real
3. scripts/config.env with real secrets

## H) Quick readiness checklist

1. OIDC role exists in AWS IAM with GitHub trust policy.
2. AWS_ROLE_TO_ASSUME secret is set in GitHub.
3. All required GitHub variables are set.
4. Deploy workflow is triggered from Actions tab.
5. First run uses create_cluster=true.
