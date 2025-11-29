# Generic Error Handling in API Management

## Deploy

You need to have an API Management service already created in Azure. See [Azure Integration Services Quickstart](https://github.com/ronaldbosma/azure-integration-services-quickstart) for an easy way to create one.

Follow these steps to deploy the APIs to an existing API Management service:
1. Open a terminal and navigate to this directory.
1. Run the following command to deploy the API using Azure CLI. Replace `<your-resource-group-name>` and `<your-api-management-service-name>` with your actual values.

    ```
    az deployment group create `
        --name "generic-error-handling" `
        --resource-group "<your-resource-group-name>" `
        --template-file './main.bicep' `
        --parameters apiManagementServiceName="<your-api-management-service-name>" `
        --verbose
    ```
