//=============================================================================
// Catch-All API in API Management
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

//=============================================================================
// Variables
//=============================================================================

var httpMethodsToCatch string[] = [ 
  'GET'
  'POST'
  'PUT'
  'PATCH'
  'DELETE'
]

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource catchAllApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  name: 'catch-all-api'
  parent: apiManagementService
  properties: {
    displayName: 'Catch-All API'
    path: 'catch-all'
    type: 'http'
    serviceUrl: 'https://echo.playground.azure-api.net/api'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }

  // Add a 'catch-all' operation for each specified method
  resource operations 'operations' = [for method in httpMethodsToCatch: {
    name: method
    properties: {
      displayName: method
      method: method
      urlTemplate: '/{*path}'
      templateParameters: [
        {
          name: 'path'
          type: 'string'
          required: true
        }
      ]
    }
  }]
}
