$deletedApimInstances = az apim deletedservice list `
    --query "[].{name:name, location:location}" `
    --output json | ConvertFrom-Json


# List all found deleted API Management instances and ask for confirmation
Write-Output "The following deleted API Management instaces were found:"
$deletedApimInstances | Format-Table -AutoSize

$confirmation = Read-Host "Do you want to proceed with purging these API Management instances? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Output "Operation canceled by the user."
    exit
}

foreach ($instance in $deletedApimInstances) {
    Write-Output "Purging API Management instance: $($instance.name) in location: $($instance.location)"
    az apim deletedservice purge --location $instance.location --service-name $instance.name
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Failed to purge API Management instance: $($instance.name)"
    }
    else {
        Write-Output "Successfully purged API Management instance: $($instance.name)"
    }
}