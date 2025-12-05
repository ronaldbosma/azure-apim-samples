# Generic Error Handling

This sample demonstrates how to implement generic error handling in Azure API Management. 
It includes:
- A global policy that implements generic error handling logic.
- A Error Handling API that calls the Backend API and implements different error handling scenarios.
- A Backend API that simulates a service returning various status codes.

See the blog post [Generic Error Handling in API Management](https://ronaldbosma.github.io/blog/2025/12/01/generic-error-handling-in-api-management/) for a more detailed explanation.

## How it works

In the outbound section on the global scope, there is error handling that follows these requirements:
- By default, if an error occured and the `errorHandled` variable is not set or false:
	- If the status code is in the `passthroughErrorStatusCodes` variable (default list: 404 Not Found, 409 Conflict, 413 Content Too Large, 429 Too Many Requests):
		- Do not change the status code
        - Clear the body
    - For all other errors, return a 500 Internal Server Error with an empty body

An API or operation can override the default behaviour in these ways:
- Do their own error handling and set `errorHandled` to true before the global logic is executed.
- Change status codes before the global error handling is executed.  
  Scenario: In some cases, a backend will return a 200 but the response body will indicate a failure. In the API/operation, you can change the status code to a more appropriate value before the global logic is executed.
- Change the `passthroughErrorStatusCodes` variable to configure less or more status codes to passthrough.


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


## Test

The [tests](./tests) folder contains a .NET 10 solution with automated tests that validate the different error handling scenarios.

### Before running the tests

Update the value of the `ApimBaseUrl` in [test.runsettings](./tests/test.runsettings) to your API Management service URL.

### Run the tests in Visual Studio

- Open the `GenericErrorHandling.Tests.slnx` solution in Visual Studio.
- Build the solution.
- Execute the tests.

  If you get the following error, the `test.runsettings` file is not loaded correctly:

  ```
  System.Collections.Generic.KeyNotFoundException: The given key 'ApimBaseUrl' was not present in the dictionary.
  ```
  
  Select the `test.runsettings` file explicitly in Visual Studio via: Test > Configure Run Settings > Select Solution Wide runsettings File > select the `test.runsettings` file.

### Run the tests from the command line

- Open a terminal and navigate to the [tests](./tests) folder.
- Run the following command:
  
  ```
  dotnet run --settings test.runsettings
  ```
