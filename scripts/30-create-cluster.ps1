$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command eksctl
Require-Command aws

$repoRoot = Get-RepoRoot
$templatePath = Join-Path $repoRoot "infra/eksctl/cluster-config.yaml.tpl"
$outputPath = Join-Path $repoRoot "infra/eksctl/cluster-config.generated.yaml"

$clusterName = Require-Env "CLUSTER_NAME"
$region = Require-Env "AWS_REGION"
$nodeType = Require-Env "NODE_TYPE"
$nodeCount = Require-Env "NODE_COUNT"

$content = Get-Content $templatePath -Raw
$content = $content.Replace("__CLUSTER_NAME__", $clusterName)
$content = $content.Replace("__AWS_REGION__", $region)
$content = $content.Replace("__NODE_TYPE__", $nodeType)
$content = $content.Replace("__NODE_COUNT__", $nodeCount)
Set-Content -Path $outputPath -Value $content

eksctl create cluster -f $outputPath | Out-Host
aws eks update-kubeconfig --region $region --name $clusterName | Out-Host
kubectl get nodes | Out-Host
