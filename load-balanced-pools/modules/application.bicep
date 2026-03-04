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

@description('The settings for the region')
param settings regionalSettingsType

@description('The name of the Function App in the primary region')
param primaryFunctionAppName string

@description('The name of the Function App in the secondary region')
param secondaryFunctionAppName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2024-10-01-preview' existing = {
  name: settings.apiManagementServiceName
}

resource functionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: settings.functionAppName
}

resource primaryFunctionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: primaryFunctionAppName
}

resource secondaryFunctionApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: secondaryFunctionAppName
}

//=============================================================================
// Resources
//=============================================================================

// Backends

resource primaryBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: 'primary-backend'
  properties: {
    description: 'The backend for the primary region'
    url: 'https://${primaryFunctionApp.properties.defaultHostName}'
    protocol: 'http'
    credentials: {
      header: {
        'x-functions-key': [
          listKeys('${primaryFunctionApp.id}/host/default', primaryFunctionApp.apiVersion).functionKeys.default
        ]
      }
    }
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource secondaryBackend 'Microsoft.ApiManagement/service/backends@2024-10-01-preview' = {
  parent: apiManagementService
  name: 'secondary-backend'
  properties: {
    description: 'The backend for the secondary region'
    url: 'https://${secondaryFunctionApp.properties.defaultHostName}'
    protocol: 'http'
    credentials: {
      header: {
        'x-functions-key': [
          listKeys('${secondaryFunctionApp.id}/host/default', secondaryFunctionApp.apiVersion).functionKeys.default
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
          id: primaryBackend.id
          priority: settings.isPrimaryRegion ? 1 : 2
          weight: settings.isPrimaryRegion ? 100 : 0
        }
        {
          id: secondaryBackend.id
          priority: settings.isPrimaryRegion ? 2 : 1
          weight: settings.isPrimaryRegion ? 0 : 100
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
    siteName: settings.functionAppName
    currentAppSettings: list('${functionApp.id}/config/appsettings', functionApp.apiVersion).properties
    newAppSettings: {
      IS_PRIMARY_REGION: toLower(string(settings.isPrimaryRegion))
    }
  }
}
