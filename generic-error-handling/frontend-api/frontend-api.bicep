//=============================================================================
// Frontend API in API Management
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

// Localhost backend for forwarding requests to other APIs in the same APIM instance
resource localhostBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: 'localhost'
  properties: {
    description: 'The localhost backend. Can be used to call other APIs hosted in the same API Management instance.'

    // Note: This configuration uses the public gateway URL for the backend.
    // For APIM instances running inside a VNet, you would typically use https://localhost as the backend URL.
    url: apiManagementService.properties.gatewayUrl
    protocol: 'http'
    
    // Note: The Host header configuration is only necessary when the backend URL is set to https://localhost.
    // For public gateway URLs, this configuration can be omitted.
    credentials: {
      header: {
        Host: [parseUri(apiManagementService.properties.gatewayUrl).host]
      }
    }
    
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource frontendApi 'Microsoft.ApiManagement/service/apis@2024-10-01-preview' = {
  name: 'frontend-api'
  parent: apiManagementService
  dependsOn: [localhostBackend]
  properties: {
    path: 'frontend'
    format: 'openapi'
    value: loadTextContent('openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    // Disable subscription requirement for demo purposes
    subscriptionRequired: false
  }
  
  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('frontend-api.xml')
    }
    dependsOn: [localhostBackend]
  }
}

resource defaultBehaviourOperation 'Microsoft.ApiManagement/service/apis/operations@2024-10-01-preview' existing = {
  name: 'defaultBehaviour'
  parent: frontendApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('operations/defaultBehaviour.xml')
    }
  }
}

resource errorHandledOperation 'Microsoft.ApiManagement/service/apis/operations@2024-10-01-preview' existing = {
  name: 'errorHandled'
  parent: frontendApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('operations/errorHandled.xml')
    }
  }
}
