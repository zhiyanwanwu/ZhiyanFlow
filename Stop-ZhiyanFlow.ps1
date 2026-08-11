$ErrorActionPreference = 'Stop'

$composeDir = Join-Path $PSScriptRoot 'docker'

Push-Location $composeDir
try {
    docker compose `
        -f docker-compose.yml `
        -f docker-compose.zhiyanflow.yml `
        stop
} finally {
    Pop-Location
}
