$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command kubectl

$release = Require-Env "HELM_RELEASE_NAME"
$namespace = Require-Env "K8S_NAMESPACE"
$serviceName = "${release}-flask-kafka-app"

$hostname = kubectl get svc $serviceName -n $namespace -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
if (-not $hostname) {
    $hostname = kubectl get svc $serviceName -n $namespace -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
}
if (-not $hostname) {
    throw "Service endpoint not available yet for $serviceName in namespace $namespace"
}

$message = "assessment-message-$(Get-Date -Format yyyyMMddHHmmss)"
$body = @{ message = $message } | ConvertTo-Json

$publishResult = Invoke-RestMethod -Method Post -Uri "http://$hostname/kafka/publish" -Body $body -ContentType "application/json"
$lastMessageResult = Invoke-RestMethod -Method Get -Uri "http://$hostname/kafka/last-message"

Write-Host "Publish response:" 
$publishResult | ConvertTo-Json -Depth 6 | Out-Host

Write-Host "Last consumed message response:" 
$lastMessageResult | ConvertTo-Json -Depth 6 | Out-Host
