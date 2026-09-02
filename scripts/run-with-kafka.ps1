$ErrorActionPreference = "Stop"

& "$PSScriptRoot/10-bootstrap.ps1"
& "$PSScriptRoot/20-build-push.ps1"
& "$PSScriptRoot/30-create-cluster.ps1"
& "$PSScriptRoot/35-install-kafka.ps1"
& "$PSScriptRoot/40-deploy-helm.ps1"
& "$PSScriptRoot/50-verify.ps1"
& "$PSScriptRoot/46-kafka-smoke-test.ps1"
