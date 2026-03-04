param (
    [string]$Location = 'swedencentral'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Print the time and date before starting the deployment
Write-Host "Start deployment at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"

# Deploy at subscription level using the bicepparam file
az deployment sub create `
    --name "deploy-load-balanced-pools-$(Get-Date -Format "yyyyMMdd-HHmmss")" `
    --location $Location `
    --parameters ./infra/main.bicepparam `
    --verbose

Write-Host "Deployment completed at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
