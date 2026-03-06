param (
    # Flags to control what to deploy. If neither is specified, both infra and function will be deployed
    [switch]$DeployInfra,
    [switch]$DeployFunction,

    # Parameters for deployment
    [Parameter(Mandatory = $true)][string]$Location,
    [Parameter(Mandatory = $true)][string]$FirstResourceGroupName,
    [Parameter(Mandatory = $true)][string]$FirstApiManagementServiceName,
    [Parameter(Mandatory = $true)][string]$FirstFunctionAppName,
    [Parameter(Mandatory = $true)][string]$SecondResourceGroupName,
    [Parameter(Mandatory = $true)][string]$SecondApiManagementServiceName,
    [Parameter(Mandatory = $true)][string]$SecondFunctionAppName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# If neither flag is specified, deploy both
if (-not $DeployInfra -and -not $DeployFunction) {
    $DeployInfra = $true
    $DeployFunction = $true
}

# Deploy infrastructure
if ($DeployInfra) {
    Write-Host "Start infra deployment at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"

    # Deploy at subscription level using the bicepparam file
    az deployment sub create `
        --name "deploy-load-balanced-pools-$(Get-Date -Format "yyyyMMdd-HHmmss")" `
        --location $Location `
        --parameters ./infra/main.bicepparam `
        --parameters firstResourceGroupName=$FirstResourceGroupName `
        --parameters firstApiManagementServiceName=$FirstApiManagementServiceName `
        --parameters firstFunctionAppName=$FirstFunctionAppName `
        --parameters secondResourceGroupName=$SecondResourceGroupName `
        --parameters secondApiManagementServiceName=$SecondApiManagementServiceName `
        --parameters secondFunctionAppName=$SecondFunctionAppName `
        --verbose

    Write-Host "Infra deployment completed at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
}

# Build and publish the function app
if ($DeployFunction) {
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

        # Deploy to first region function app
        Write-Host ""
        Write-Host "Publishing to first region function app '$FirstFunctionAppName' at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
        az functionapp deployment source config-zip `
            --resource-group $FirstResourceGroupName `
            --name $FirstFunctionAppName `
            --src ./publish.zip `
            --build-remote false

        # Deploy to second region function app
        Write-Host ""
        Write-Host "Publishing to second region function app '$SecondFunctionAppName' at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
        az functionapp deployment source config-zip `
            --resource-group $SecondResourceGroupName `
            --name $SecondFunctionAppName `
            --src ./publish.zip `
            --build-remote false

        Write-Host ""
        Write-Host "Function deployment completed at: $(Get-Date -Format "dd-MM-yyyy HH:mm:ss")"
    }
    finally {
        Pop-Location
    }
}
