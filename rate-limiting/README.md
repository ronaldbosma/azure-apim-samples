# Rate Limiting

Example that contains several scenarios to show the workings of the `rate-limit` and `rate-limit-by-key` policies in Azure API Management.

This sample includes:
- Two 'rate-limit' APIs that use the `rate-limit` policy to limit calls on the API and operation scope.
- Two 'rate-limit-by-key' APIs that use the `rate-limit-by-key` policy to limit calls on the API and operation scope.
- A 'rate-limit via fragment' API, that uses a policy fragment containing the `rate-limit` policy to limit calls.
- Two subscriptions with access to all APIs.
- A product that provides access to the 'rate-limit' APIs and uses the `rate-limit` policy to limit calls on the product scope. Two subscriptions are subscribed to this product.

## Deploy

You need to have an API Management service already created in Azure. See [Azure Integration Services Quickstart](https://github.com/ronaldbosma/azure-integration-services-quickstart) for an easy way to create one.  
**IMPORTANT**: Change the API Management service SKU from `Consumption` to for example `BasicV2` in order for the `rate-limit-by-key` policy to work.

Follow these steps to deploy the API to an existing API Management service:
1. Open a terminal and navigate to this directory.
1. Run the following command to deploy the API using Azure CLI. Replace `<your-resource-group-name>` and `<your-api-management-service-name>` with your actual values.

    ```
    az deployment group create `
        --name "deploy-rate-limit-samples" `
        --resource-group "<your-resource-group-name>" `
        --template-file './main.bicep' `
        --parameters apiManagementServiceName="<your-api-management-service-name>" `
        --verbose
    ```

## Test

Follow these steps to test the API:
1. Open the [tests.http](tests.http) file in an IDE that supports HTTP requests, such as Visual Studio Code.
1. Change the base URL to your API Management service URL, e.g. `https://apim-aisquick-sdc-5spzh.azure-api.net`. 
1. Change the subscription key to a valid subscription key for your API Management service, or clear the value to call APIs without a subscription key.
1. Execute the requests to call the various APIs and observe the rate limiting behavior.
