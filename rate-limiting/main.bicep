//=============================================================================
// Rate Limiting Samples
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

//=============================================================================
// Resources
//=============================================================================

module rateLimitApi1 'rate-limit-api/rate-limit-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'rate-limit-api-1'
    displayName: 'rate-limit API 1'
    path: 'rate-limit-1'
  }
}


module rateLimitApi2 'rate-limit-api/rate-limit-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'rate-limit-api-2'
    displayName: 'rate-limit API 2'
    path: 'rate-limit-2'
  }
}
