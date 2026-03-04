//=============================================================================
// Application
//=============================================================================

//=============================================================================
// Imports
//=============================================================================

import { regionalSettingsType } from './types.bicep'

//=============================================================================
// Parameters
//=============================================================================

@description('The settings for the current region')
param currentRegionSettings regionalSettingsType

@description('The settings for the other region')
param otherRegionSettings regionalSettingsType

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: currentRegionSettings.apiManagementServiceName
}

resource currentRegionFunctionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: currentRegionSettings.functionAppName
}

resource otherRegionFunctionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: otherRegionSettings.functionAppName
  scope: resourceGroup(otherRegionSettings.resourceGroupName)
}

//=============================================================================
// Resources
//=============================================================================

// Backends

resource currentRegionBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: currentRegionSettings.functionAppName
  properties: {
    description: 'The backend for the primary region'
    url: 'https://${currentRegionFunctionApp.properties.defaultHostName}'
    protocol: 'http'
    credentials: {
      header: {
        'x-functions-key': [
          listKeys('${currentRegionFunctionApp.id}/host/default', currentRegionFunctionApp.apiVersion).functionKeys.default
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource otherRegionBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: otherRegionSettings.functionAppName
  properties: {
    description: 'The backend for the secondary region'
    url: 'https://${otherRegionFunctionApp.properties.defaultHostName}'
    protocol: 'http'
    credentials: {
      header: {
        'x-functions-key': [
          listKeys('${otherRegionFunctionApp.id}/host/default', otherRegionFunctionApp.apiVersion).functionKeys.default
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

// Load balanced backend pool

resource loadBalancedPool 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: 'load-balanced-pool'
  parent: apiManagementService
  properties: {
    description: 'Load balancer for multiple regions'
    type: 'Pool'
    pool: {
      services: [
        {
          id: currentRegionBackend.id
          priority: 1
          weight: 100
        }
        {
          id: otherRegionBackend.id
          priority: 2
          weight: 0
        }
      ]
    }
  }
}

// API

resource sampleApi 'Microsoft.ApiManagement/service/apis@2024-10-01-preview' = {
  name: 'sample-api'
  parent: apiManagementService
  properties: {
    path: 'sample-api'
    format: 'openapi'
    value: loadTextContent('openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: true
  }
}

resource processRequestOperation 'Microsoft.ApiManagement/service/apis/operations@2024-10-01-preview' existing = {
  name: 'process-request'
  parent: sampleApi

  resource policies 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: loadTextContent('process-request.policy.xml')
    }
  }

  dependsOn: [
    loadBalancedPool
  ]
}

// Function App - Set standard App Settings
//  NOTE: this is done in a separate module that merges the application specific app settings with the existing ones 
//        to prevent existing app settings from being removed.

module setFunctionAppSettings './merge-app-settings.bicep' = {
  params: {
    siteName: currentRegionSettings.functionAppName
    currentAppSettings: list('${currentRegionFunctionApp.id}/config/appsettings', currentRegionFunctionApp.apiVersion).properties
    newAppSettings: {
      IS_PRIMARY_REGION: toLower(string(currentRegionSettings.isPrimaryRegion))
    }
  }
}
