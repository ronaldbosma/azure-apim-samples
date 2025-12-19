//=============================================================================
// API that uses the rate-limit policy via policy fragment
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

resource rateLimitFragment 'Microsoft.ApiManagement/service/policyFragments@2024-10-01-preview' = {
  name: 'rate-limit-fragment'
  parent: apiManagementService
  properties: {
    format: 'rawxml'
    value: loadTextContent('fragment.xml')
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2024-10-01-preview' = {
  name: 'rate-limit-via-fragment-api'
  parent: apiManagementService
  properties: {
    displayName: 'rate-limit via fragment API'
    path: 'rate-limit-via-fragment'
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }

  resource operation1 'operations' = {
    name: 'operation-1'
    properties: {
      displayName: 'operation-1'
      method: 'GET'
      urlTemplate: '/operation-1'
    }

    resource policies 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: loadTextContent('operation.xml')
      }
      dependsOn: [
        rateLimitFragment
      ]
    }
  }
  
  resource operation2 'operations' = {
    name: 'operation-2'
    properties: {
      displayName: 'operation-2'
      method: 'GET'
      urlTemplate: '/operation-2'
    }

    resource policies 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: loadTextContent('operation.xml')
      }
      dependsOn: [
        rateLimitFragment
      ]
    }
  }
  
  resource operation3 'operations' = {
    name: 'operation-3'
    properties: {
      displayName: 'operation-3'
      method: 'GET'
      urlTemplate: '/operation-3'
    }

    resource policies 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: loadTextContent('operation.xml')
      }
      dependsOn: [
        rateLimitFragment
      ]
    }
  }
}
