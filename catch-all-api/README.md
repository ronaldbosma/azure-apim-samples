# Catch-All API

This is a sample API Management API that catches all HTTP methods and forwards them to a backend service. It is designed to demonstrate how to create a catch-all API in Azure API Management. See the [catch-all-api.bicep](catch-all-api.bicep) for the implementation details.

This example uses the `serviceUrl` property of the API resource to forward all requests to https://echo.playground.azure-api.net/api, which will echo the requests it receives. You can use policies to support more advanced routing and transformations.

See the blog post [Catch-All API in Azure API Management: Forward Any Request](https://ronaldbosma.github.io/blog/2025/12/15/catch-all-api-in-azure-api-management-forward-any-request/) for more details.

## Deploy

You need to have an API Management service already created in Azure. See [Azure Integration Services Quickstart](https://github.com/ronaldbosma/azure-integration-services-quickstart) for an easy way to create one.

Follow these steps to deploy the API to an existing API Management service:
1. Open a terminal and navigate to this directory.
1. Run the following command to deploy the API using Azure CLI. Replace `<your-resource-group-name>` and `<your-api-management-service-name>` with your actual values.

    ```
    az deployment group create `
        --name "deploy-catch-all-api" `
        --resource-group "<your-resource-group-name>" `
        --template-file './catch-all-api.bicep' `
        --parameters apiManagementServiceName="<your-api-management-service-name>" `
        --verbose
    ```

## Test

Follow these steps to test the API:
1. Open the [tests.http](tests.http) file in an IDE that supports HTTP requests, such as Visual Studio Code.
1. Change the base URL to your API Management service URL, e.g. `https://<your-api-management-service-name>.azure-api.net/catch-all`. 
1. Execute the requests to call the Echo API via the Catch-All API.