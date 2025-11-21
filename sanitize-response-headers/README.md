# Sanitize Response Headers

This sample demonstrates how to sanitize response headers in Azure API Management using both allowlist and blocklist approaches.

It includes:
- A Backend API that simulates a service returning various headers.
- A Sanitizing API that applies policies to sanitize the response headers based on allowlist and blocklist methods.

## Deploy

You need to have an API Management service already created in Azure. See [Azure Integration Services Quickstart](https://github.com/ronaldbosma/azure-integration-services-quickstart) for an easy way to create one.

Follow these steps to deploy the APIs to an existing API Management service:
1. Open a terminal and navigate to this directory.
1. Run the following command to deploy the API using Azure CLI. Replace `<your-resource-group-name>` and `<your-api-management-service-name>` with your actual values.

    ```
    az deployment group create `
        --name "sanitize-response-headers" `
        --resource-group "<your-resource-group-name>" `
        --template-file './main.bicep' `
        --parameters apiManagementServiceName="<your-api-management-service-name>" `
        --verbose
    ```

## Test

Follow these steps to test the API:
1. Open the [tests.http](tests.http) file in an IDE that supports HTTP requests, such as Visual Studio Code.
1. Change the base URL to your API Management service URL, e.g. `https://<your-api-management-service-name>.azure-api.net`. 
1. Execute the requests on the Backend and Sanitizing APIs to see how the response headers are sanitized.
1. Use the parameters `numberOfSafeHeadersToReturnFromBackend` and `numberOfUnsafeHeadersToReturnFromBackend` to control how many safe and unsafe headers the Backend API returns.