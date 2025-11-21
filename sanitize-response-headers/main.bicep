//=============================================================================
// Sanitize Response Headers Bicep Template
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

//=============================================================================
// Resources
//=============================================================================

module backendApi 'backend-api/backend-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
  }
}
