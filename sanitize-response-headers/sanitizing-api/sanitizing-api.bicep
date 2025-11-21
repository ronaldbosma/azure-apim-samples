//=============================================================================
// Sanitizing API in API Management
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

// Named Values

resource apimGatewayUrlNamedValue 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  name: 'apim-gateway-url'
  parent: apiManagementService
  properties: {
    displayName: 'apim-gateway-url'
    value: apiManagementService.properties.gatewayUrl
  }
}

// API

resource sanitizingApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  name: 'sanitizing-api'
  parent: apiManagementService
  properties: {
    path: 'sanitizing'
    format: 'openapi+json'
    value: loadTextContent('sanitizing-api.openapi.yaml')
    type: 'http'
    protocols: [ 
      'https' 
    ]
    subscriptionRequired: false // No subscription required for demo purposes
  }

  dependsOn: [
    apimGatewayUrlNamedValue
  ]
}

// Operations (existing) with attached policies

resource getNoSanitizationOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  name: 'get-no-sanitization'
  parent: sanitizingApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('get-no-sanitization.xml')
    }
  }
}

resource getAllowlistOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  name: 'get-allowlist'
  parent: sanitizingApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('get-allowlist.xml')
    }
  }
}

resource getBlocklistOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' existing = {
  name: 'get-blocklist'
  parent: sanitizingApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('get-blocklist.xml')
    }
  }
}
