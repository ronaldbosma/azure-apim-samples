//=============================================================================
// API Tagging sample in API Management
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Resources
//=============================================================================

resource transitStatusApi 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: 'transit-status'
  parent: apiManagementService
  properties: {
    displayName: 'Transit Status API'
    path: 'transit-status'
    format: 'openapi'
    value: loadTextContent('apis/transit-status-api.openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}

resource bikeRentalApi 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: 'bike-rental'
  parent: apiManagementService
  properties: {
    displayName: 'Bike Rental API'
    path: 'bike-rental'
    format: 'openapi'
    value: loadTextContent('apis/bike-rental-api.openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}

resource tripPlanningApi 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: 'trip-planning'
  parent: apiManagementService
  properties: {
    displayName: 'Trip Planning API'
    path: 'trip-planning'
    format: 'openapi'
    value: loadTextContent('apis/trip-planning-api.openapi.yaml')
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}
