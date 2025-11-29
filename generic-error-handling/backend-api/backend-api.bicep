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

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource backendApi 'Microsoft.ApiManagement/service/apis@2024-10-01-preview' = {
  name: 'backend-api'
  parent: apiManagementService
  properties: {
    path: 'backend'
    format: 'openapi'
    value: loadTextContent('openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    // Disable subscription requirement for demo purposes
    subscriptionRequired: false
  }
}

resource getResponseByStatusCodeOperation 'Microsoft.ApiManagement/service/apis/operations@2024-10-01-preview' existing = {
  name: 'getResponseByStatusCode'
  parent: backendApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('operations/getResponseByStatusCode.xml') 
    }
  }
}
