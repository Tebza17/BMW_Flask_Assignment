$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command kubectl

$release = Require-Env "HELM_RELEASE_NAME"
$namespace = Require-Env "K8S_NAMESPACE"

kubectl rollout status "deployment/$release-flask-kafka-app" -n $namespace --timeout=180s | Out-Host
$serviceName = "${release}-flask-kafka-app"

$hostname = kubectl get svc $serviceName -n $namespace -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
if (-not $hostname) {
    $hostname = kubectl get svc $serviceName -n $namespace -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
}

if (-not $hostname) {
    Write-Host "Load balancer endpoint not available yet. Retry this script in a minute."
    exit 0
}

Write-Host "Application endpoint: http://$hostname"
Write-Host "Health endpoint:      http://$hostname/health"
