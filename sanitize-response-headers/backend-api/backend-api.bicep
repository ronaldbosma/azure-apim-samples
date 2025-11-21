//=============================================================================
// Backend API in API Management
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

// API

resource backendApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  name: 'backend-api'
  parent: apiManagementService
  properties: {
    path: 'backend'
    format: 'openapi+json'
    value: loadTextContent('backend-api.openapi.yaml')
    type: 'http'
    protocols: [ 
      'https' 
    ]
    subscriptionRequired: false // No subscription required for demo purposes
  }
}

resource getResponseHeadersOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  name: 'get-response-headers'
  parent: backendApi
  
  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('get-response-headers.xml')
    }
  }
}
