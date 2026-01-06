//=============================================================================
// Product
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

@description('List of APIs that are part of the product')
param apiNames array = []

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource product 'Microsoft.ApiManagement/service/products@2024-10-01-preview' = {
  name: 'rate-limiting-product'
  parent: apiManagementService
  properties: {
    displayName: 'rate-limit Product'
    description: 'rate-limit Product'
  }
  
  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('product.xml')
    }
  }

  resource apis 'apis' = [for apiName in apiNames : {
    name: apiName
  }]
}

resource subscription1 'Microsoft.ApiManagement/service/subscriptions@2024-10-01-preview' = {
  name: 'subscription-1-on-rate-limit-product'
  parent: apiManagementService
  properties: {
    displayName: 'Subscription 1 on rate-limit product'
    state: 'active'
    scope: '/product/${product.id}'
  }
}

resource subscription2 'Microsoft.ApiManagement/service/subscriptions@2024-10-01-preview' = {
  name: 'subscription-2-on-rate-limit-product'
  parent: apiManagementService
  properties: {
    displayName: 'Subscription 2 on rate-limit product'
    state: 'active'
    scope: '/product/${product.id}'
  }
}
