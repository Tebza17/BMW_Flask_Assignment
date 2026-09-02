Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
    [string]$Region = "eu-west-1",
    [string]$GitHubOrg = "Tebza17",
    [string]$GitHubRepo = "BMW_Flask_Assignment",
    [string]$GitHubBranch = "main",
    [string]$RoleName = "github-actions-eks-deployer",
    [string]$StackName = "github-oidc-eks-role"
)

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI is required. Install AWS CLI v2 and run 'aws configure' first."
}

$existingProviderArn = (
    aws iam list-open-id-connect-providers `
        --query "OpenIDConnectProviderList[?contains(Arn, 'token.actions.githubusercontent.com')].Arn | [0]" `
        --output text
).Trim()

if ($existingProviderArn -eq "None") {
    $existingProviderArn = ""
}

aws cloudformation deploy `
    --region $Region `
    --stack-name $StackName `
    --template-file "iam/oidc-role-stack.yaml" `
    --capabilities CAPABILITY_NAMED_IAM `
    --parameter-overrides `
        "GitHubOrg=$GitHubOrg" `
        "GitHubRepo=$GitHubRepo" `
        "GitHubBranch=$GitHubBranch" `
        "RoleName=$RoleName" `
        "ExistingOidcProviderArn=$existingProviderArn"

$roleArn = (
    aws cloudformation describe-stacks `
        --region $Region `
        --stack-name $StackName `
        --query "Stacks[0].Outputs[?OutputKey=='GitHubActionsRoleArn'].OutputValue" `
        --output text
).Trim()

Write-Host ""
Write-Host "Created/updated IAM role ARN: $roleArn"
Write-Host "Ensure GitHub secret AWS_ROLE_TO_ASSUME matches this ARN."
