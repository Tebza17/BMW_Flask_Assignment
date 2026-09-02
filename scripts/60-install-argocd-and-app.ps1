$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command kubectl

$repoRoot = Get-RepoRoot
$appManifest = Join-Path $repoRoot "gitops/argocd/application-prod.generated.yaml"

& "$PSScriptRoot/61-render-argocd-app.ps1"

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f - | Out-Host
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | Out-Host
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s | Out-Host

kubectl apply -f $appManifest | Out-Host
kubectl get applications -n argocd | Out-Host
