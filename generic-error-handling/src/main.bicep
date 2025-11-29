//=============================================================================
// Application Resources
// These are pure Bicep and can't be deployed separately by azd yet
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

resource globalPolicy 'Microsoft.ApiManagement/service/policies@2024-10-01-preview' = {
  parent: apiManagementService
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('global.xml')
  }
}

module backendApi 'backend-api/backend-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
  }
}

module frontendApi 'frontend-api/frontend-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
  }
}
