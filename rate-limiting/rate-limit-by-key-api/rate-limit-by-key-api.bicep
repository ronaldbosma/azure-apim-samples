//=============================================================================
// API that uses the rate-limit-by-key policy
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

@description('The path for the API')
param path string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource api 'Microsoft.ApiManagement/service/apis@2024-10-01-preview' = {
  name: name
  parent: apiManagementService
  properties: {
    displayName: displayName
    path: path
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('api.xml')
    }
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
    }
  }
}

//=============================================================================
// Outputs
//=============================================================================

output apiName string = api.name
