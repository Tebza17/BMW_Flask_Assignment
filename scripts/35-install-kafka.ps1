$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command helm
Require-Command kubectl

$repoRoot = Get-RepoRoot
$kafkaValues = Join-Path $repoRoot "infra/kafka/values.yaml"

helm repo add bitnami https://charts.bitnami.com/bitnami | Out-Host
helm repo update | Out-Host

helm upgrade --install kafka bitnami/kafka -n kafka --create-namespace -f $kafkaValues | Out-Host

kubectl get pods -n kafka | Out-Host
kubectl get svc -n kafka | Out-Host

Write-Host "Kafka bootstrap server for this setup: kafka.kafka.svc.cluster.local:9092"
