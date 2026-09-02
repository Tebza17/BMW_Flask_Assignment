$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command eksctl
Require-Command aws

$clusterName = Require-Env "CLUSTER_NAME"
$region = Require-Env "AWS_REGION"
$repoName = Require-Env "ECR_REPOSITORY_NAME"

Write-Host "Deleting EKS cluster: $clusterName"
eksctl delete cluster --name $clusterName --region $region | Out-Host

Write-Host "Deleting ECR repository: $repoName"
aws ecr delete-repository --repository-name $repoName --force --region $region | Out-Host
