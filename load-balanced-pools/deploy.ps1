param (
    [switch]$Infra,
    [switch]$Function,
    [string]$Location = 'swedencentral',
    [string]$PrimaryFunctionAppName = 'func-primary-sdc-orfff',
    [string]$PrimaryResourceGroupName = 'rg-primary-sdc-orfff',
    [string]$SecondaryFunctionAppName = 'func-secondary-nwe-g5bv4',
    [string]$SecondaryResourceGroupName = 'rg-secondary-nwe-g5bv4'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# If neither flag is specified, deploy both
if (-not $Infra -and -not $Function) {
    $Infra = $true
    $Function = $true
}

# Deploy infrastructure
if ($Infra) {
    Write-Host "Start infra deployment at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"

    # Deploy at subscription level using the bicepparam file
    az deployment sub create `
        --name "deploy-load-balanced-pools-$(Get-Date -Format "yyyyMMdd-HHmmss")" `
        --location $Location `
        --parameters ./infra/main.bicepparam `
        --verbose

    Write-Host "Infra deployment completed at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
}

# Build and publish the function app
if ($Function) {
    Write-Host ""
    Write-Host "Building dotnet project at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"

    Push-Location -Path ./src
    try {
        # Build the project
        dotnet build --configuration Release

        # Publish the project
        dotnet publish --configuration Release --output ./publish

        # Create zip file for deployment
        Write-Host ""
        Write-Host "Creating deployment package at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
        if (Test-Path ./publish.zip) {
            Remove-Item ./publish.zip -Force
        }
        Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip

        # Deploy to primary region function app
        Write-Host ""
        Write-Host "Publishing to primary region function app '$PrimaryFunctionAppName' at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
        az functionapp deployment source config-zip `
            --resource-group $PrimaryResourceGroupName `
            --name $PrimaryFunctionAppName `
            --src ./publish.zip `
            --build-remote false

        # Deploy to secondary region function app
        Write-Host ""
        Write-Host "Publishing to secondary region function app '$SecondaryFunctionAppName' at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
        az functionapp deployment source config-zip `
            --resource-group $SecondaryResourceGroupName `
            --name $SecondaryFunctionAppName `
            --src ./publish.zip `
            --build-remote false

        Write-Host ""
        Write-Host "Function deployment completed at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
    }
    finally {
        Pop-Location
    }
}


