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

// APIs using the rate-limit policy

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


// APIs using the rate-limit-by-key policy

module rateLimitByKeyApi1 'rate-limit-by-key-api/rate-limit-by-key-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'rate-limit-by-key-api-1'
    displayName: 'rate-limit-by-key API 1'
    path: 'rate-limit-by-key-1'
  }
}

module rateLimitByKeyApi2 'rate-limit-by-key-api/rate-limit-by-key-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'rate-limit-by-key-api-2'
    displayName: 'rate-limit-by-key API 2'
    path: 'rate-limit-by-key-2'
  }
}


// API using the rate-limit policy via fragment

module rateLimitViaFragmentApi 'rate-limit-via-fragment-api/rate-limit-via-fragment-api.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
  }
}


// Subscriptions for testing that can access all APIs

module subscription1 'subscription/subscription.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'subscription-1'
    displayName: 'Subscription 1'
  }
}

module subscription2 'subscription/subscription.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: 'subscription-2'
    displayName: 'Subscription 2'
  }
}


// Product with subscriptions that gives access to the rate-limit APIs

module productWithSubscriptions 'product-with-subscriptions/product-with-subscriptions.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    apiNames: [
      rateLimitApi1.outputs.apiName
      rateLimitApi2.outputs.apiName
    ]
  }
}
