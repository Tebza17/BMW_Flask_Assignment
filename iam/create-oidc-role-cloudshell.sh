#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="github-oidc-eks-role"
REGION="${1:-us-east-1}"
GITHUB_ORG="${2:-Tebza17}"
GITHUB_REPO="${3:-BMW_Flask_Assignment}"
GITHUB_BRANCH="${4:-main}"
ROLE_NAME="${5:-github-actions-eks-deployer}"

EXISTING_PROVIDER_ARN=$(aws iam list-open-id-connect-providers \
  --query "OpenIDConnectProviderList[?contains(Arn, 'token.actions.githubusercontent.com')].Arn | [0]" \
  --output text)

if [[ "${EXISTING_PROVIDER_ARN}" == "None" ]]; then
  EXISTING_PROVIDER_ARN=""
fi

aws cloudformation deploy \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --template-file iam/oidc-role-stack.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    GitHubOrg="${GITHUB_ORG}" \
    GitHubRepo="${GITHUB_REPO}" \
    GitHubBranch="${GITHUB_BRANCH}" \
    RoleName="${ROLE_NAME}" \
    ExistingOidcProviderArn="${EXISTING_PROVIDER_ARN}"

ROLE_ARN=$(aws cloudformation describe-stacks \
  --region "${REGION}" \
  --stack-name "${STACK_NAME}" \
  --query "Stacks[0].Outputs[?OutputKey=='GitHubActionsRoleArn'].OutputValue" \
  --output text)

echo ""
echo "Created/updated IAM role ARN: ${ROLE_ARN}"
echo "Set this as GitHub Secret AWS_ROLE_TO_ASSUME"
