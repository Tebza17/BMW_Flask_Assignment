$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Load-Config

$repoRoot = Get-RepoRoot
$templatePath = Join-Path $repoRoot "gitops/argocd/application-prod.yaml.tpl"
$outputPath = Join-Path $repoRoot "gitops/argocd/application-prod.generated.yaml"

$repoUrl = Require-Env "GIT_REPO_URL"

$content = Get-Content $templatePath -Raw
$content = $content.Replace("__REPO_URL__", $repoUrl)
Set-Content -Path $outputPath -Value $content

Write-Host "Rendered: $outputPath"
