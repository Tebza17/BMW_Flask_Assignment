$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command aws
Require-Command docker
Require-Command kubectl
Require-Command eksctl
Require-Command helm

$region = Require-Env "AWS_REGION"
$repoName = Require-Env "ECR_REPOSITORY_NAME"
$accountId = Require-Env "AWS_ACCOUNT_ID"

Write-Host "Verifying AWS identity..."
aws sts get-caller-identity | Out-Host

Write-Host "Ensuring ECR repository exists..."
$repoExists = $true
try {
    aws ecr describe-repositories --repository-names $repoName --region $region | Out-Null
} catch {
    $repoExists = $false
}

if (-not $repoExists) {
    aws ecr create-repository --repository-name $repoName --region $region | Out-Host
}

Write-Host "Logging Docker in to ECR..."
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$accountId.dkr.ecr.$region.amazonaws.com" | Out-Host

Write-Host "Bootstrap complete."
