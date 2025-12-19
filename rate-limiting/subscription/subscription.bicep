//=============================================================================
// Subscription
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

@description('The name of the API')
param name string

@description('The display name for the API')
param displayName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource subscription 'Microsoft.ApiManagement/service/subscriptions@2024-10-01-preview' = {
  name: name
  parent: apiManagementService
  properties: {
    displayName: displayName
    state: 'active'
    scope: '/apis' // NOTE: This will grant access to all APIs, which is considered a bad practice for production use cases.
  }
}
