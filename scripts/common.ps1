Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    return Split-Path -Parent $PSScriptRoot
}

function Load-Config {
    $configPath = Join-Path $PSScriptRoot "config.env"
    if (-not (Test-Path $configPath)) {
        throw "Missing scripts/config.env. Copy scripts/config.env.example to scripts/config.env and set values."
    }

    Get-Content $configPath | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }

        $parts = $line.Split("=", 2)
        if ($parts.Length -ne 2) { return }

        $name = $parts[0].Trim()
        $value = $parts[1].Trim()
        [Environment]::SetEnvironmentVariable($name, $value)
        Set-Item -Path "Env:$name" -Value $value
    }
}

function Require-Command([string]$name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $name"
    }
}

function Require-Env([string]$name) {
    $value = (Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Missing required environment variable in config.env: $name"
    }
    return $value
}

function Get-EcrRepoUri {
    $accountId = Require-Env "AWS_ACCOUNT_ID"
    $region = Require-Env "AWS_REGION"
    $repoName = Require-Env "ECR_REPOSITORY_NAME"
    return "$accountId.dkr.ecr.$region.amazonaws.com/$repoName"
}
