//=============================================================================
// Convert File API in API Management
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

resource convertFileApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  name: 'convert-file'
  parent: apiManagementService
  properties: {
    path: 'convert-file'
    format: 'openapi'
    value: loadTextContent('convert-file-api.openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}

resource convertFileOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  name: 'convertFile'
  parent: convertFileApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('convert-file.policy.xml') 
    }
  }
}
