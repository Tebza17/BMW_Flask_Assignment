$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command helm
Require-Command kubectl

$repoRoot = Get-RepoRoot
$chartPath = Join-Path $repoRoot "helm/flask-kafka-app"

$release = Require-Env "HELM_RELEASE_NAME"
$namespace = Require-Env "K8S_NAMESPACE"
$imageTag = Require-Env "IMAGE_TAG"
$repoUri = Get-EcrRepoUri

helm lint $chartPath | Out-Host
helm upgrade --install $release $chartPath -n $namespace --create-namespace -f "$chartPath/values-dev.yaml" --set image.repository=$repoUri --set image.tag=$imageTag | Out-Host

kubectl get pods -n $namespace | Out-Host
kubectl get svc -n $namespace | Out-Host
