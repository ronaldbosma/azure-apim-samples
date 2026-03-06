//=============================================================================
// Application
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service instance in the current region')
param apiManagementServiceName string

@description('The name of the Function App backend in the current region')
param functionAppName string

@description('The name of the Function App backend in the other region')
param otherFunctionAppName string

@description('The name of the resource group where the Function App backend in the other region is located')
param otherFunctionAppResourceGroupName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

// Backends

module currentRegionBackend './backend.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    functionAppResourceGroupName: resourceGroup().name
    functionAppName: functionAppName
  }
}

module otherRegionBackend './backend.bicep' = {
  params: {
    apiManagementServiceName: apiManagementServiceName
    functionAppResourceGroupName: otherFunctionAppResourceGroupName
    functionAppName: otherFunctionAppName
  }
}

// Load balanced backend pool

resource loadBalancedPool 'Microsoft.ApiManagement/service/backends@2025-03-01-preview' = {
  name: 'load-balanced-pool'
  parent: apiManagementService
  properties: {
    description: 'Load balancer for multiple regions'
    type: 'Pool'
    pool: {
      services: [
        {
          id: currentRegionBackend.outputs.functionAppBackendId
          priority: 1
        }
        {
          id: otherRegionBackend.outputs.functionAppBackendId
          priority: 2
        }
      ]
    }
  }
}

// API

resource resilientApi 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: 'resilient-api'
  parent: apiManagementService
  properties: {
    path: 'resilient-api'
    format: 'openapi'
    value: loadTextContent('openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}

resource processRequestOperation 'Microsoft.ApiManagement/service/apis/operations@2025-03-01-preview' existing = {
  name: 'process-request'
  parent: resilientApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('process-request.policy.xml')
    }

    dependsOn: [
      loadBalancedPool
    ]
  }
}
