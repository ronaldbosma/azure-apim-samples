# API Tagging

In this sample, we demonstrate how to use API tags in Azure API Management to categorize and organize APIs. 
It shows how to deploy API tags at the API level and optionally bubble up tags from the operation level based on the OpenAPI specifications.

This sample includes 3 APIs: Bike Rental API, Transit Status API and Trip Planning API. 
Each API has been assigned a set of tags at the API level and the OpenAPI specifications of the APIs can have additional tags defined at the operation level.
See the table below for an overview of the tags assigned to each API:

| API                | API Tags           | Operation level tags      |
| ------------------ | ------------------ | ------------------------- |
| Bike Rental API    | mobility           | public                    |
| Transit Status API | mobility           |                           |
| Trip Planning API  | mobility, planning | planning, pricing, public |

## Prerequisites

Before deploying, make sure you have the following:
- Azure CLI installed and authenticated (`az login`).
- An Azure API Management (APIM) instance where you have permissions to deploy resources.

## Deploy

You can use the following command (PowerShell) to deploy this sample. Make sure to update the parameters with your own values.

```pwsh
$resourceGroupName = "<your-resource-group-name>"
$apiManagementServiceName = "<your-api-management-service-name>"
$addOperationTagsToApi = $false

az deployment group create `
    --name "deploy-api-tagging-sample" `
    --resource-group $resourceGroupName `
    --template-file './main.bicep' `
    --parameters apiManagementServiceName=$apiManagementServiceName addOperationTagsToApi=$addOperationTagsToApi `
    --verbose
```

Tip: First deploy the sample with `$addOperationTagsToApi` set to `$false` to only add tags at the API level. 
After deployment, you can check the APIM instance to see the assigned tags for each API. 
Then, deploy the sample again with `$addOperationTagsToApi` set to `$true` to also add operation-level tags to the APIs based on the OpenAPI specifications. 
You can then compare the differences in tags assigned to APIs in the APIM instance.
