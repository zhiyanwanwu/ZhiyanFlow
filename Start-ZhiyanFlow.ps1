$ErrorActionPreference = 'Stop'

$composeDir = Join-Path $PSScriptRoot 'docker'
$dockerDesktop = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    if (-not (Test-Path $dockerDesktop)) {
        throw 'Docker Desktop is not installed.'
    }

    Start-Process $dockerDesktop -WindowStyle Hidden
    Write-Host 'Waiting for Docker Desktop...'
    do {
        Start-Sleep -Seconds 3
        docker info *> $null
    } until ($LASTEXITCODE -eq 0)
}

Push-Location $composeDir
try {
    docker compose `
        -f docker-compose.yml `
        -f docker-compose.zhiyanflow.yml `
        up -d --pull never
} finally {
    Pop-Location
}

Start-Process 'http://127.0.0.1/'
