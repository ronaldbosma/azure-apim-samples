//=============================================================================
// Function App Backend
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The name of the Function App backend')
param functionAppName string

@description('The name of the resource group where the Function App backend is located')
param functionAppResourceGroupName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource functionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: functionAppName
  scope: resourceGroup(functionAppResourceGroupName)
}

//=============================================================================
// Resources
//=============================================================================

resource functionAppBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: functionAppName
  properties: {
    description: 'The backend for the primary region'
    url: 'https://${functionApp.properties.defaultHostName}'
    protocol: 'http'
    credentials: {
      header: {
        'x-functions-key': [
          listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
        ]
      }
    }
    circuitBreaker: {
      rules: [
        {
          name: 'rule'
          tripDuration: 'PT30S'
          acceptRetryAfter: true
          failureCondition: {
            count: 3
            errorReasons: [
              'Server errors'
            ]
            interval: 'PT15S'
            statusCodeRanges: [
              {
                min: 502 // Bad Gateway
                max: 504 // Gateway Timeout
              }
            ]
          }
        }
      ]
    }
  }
}

//=============================================================================
// Outputs
//=============================================================================

output functionAppBackendId string = functionAppBackend.id
