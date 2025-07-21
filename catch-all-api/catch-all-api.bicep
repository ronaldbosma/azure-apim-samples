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

var apiName = 'catch-all-api'
var apiDisplayName = 'Catch-All API'
var apiPath = 'catch-all'
var httpMethodsToCatch = [ 'GET', 'POST', 'PUT', 'PATCH', 'DELETE' ]
var backedServiceUrl = 'https://echo.playground.azure-api.net/api'

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
  name: apiName
  parent: apiManagementService
  properties: {
    displayName: apiDisplayName
    path: apiPath
    type: 'http'
    serviceUrl: backedServiceUrl
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
