$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config
Require-Command docker

$imageTag = Require-Env "IMAGE_TAG"
$repoUri = Get-EcrRepoUri
$repoRoot = Get-RepoRoot
$appPath = Join-Path $repoRoot "app"

Push-Location $appPath
try {
    docker build -t "flask-kafka-app:$imageTag" . | Out-Host
    docker tag "flask-kafka-app:$imageTag" "$repoUri:$imageTag"
    docker push "$repoUri:$imageTag" | Out-Host
} finally {
    Pop-Location
}

Write-Host "Image pushed: $repoUri:$imageTag"
