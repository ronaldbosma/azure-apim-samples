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

// Tags

resource mobilityTag 'Microsoft.ApiManagement/service/tags@2025-03-01-preview' = {
  parent: apiManagementService
  name: 'mobility'
  properties: {
    displayName: 'mobility'
  }
}

resource publicTag 'Microsoft.ApiManagement/service/tags@2025-03-01-preview' = {
  parent: apiManagementService
  name: 'public'
  properties: {
    displayName: 'public'
  }
}

resource planningTag 'Microsoft.ApiManagement/service/tags@2025-03-01-preview' = {
  parent: apiManagementService
  name: 'planning'
  properties: {
    displayName: 'planning'
  }
}

// Transit Status API tagged with 'Mobility'

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

resource transitStatusApiMobilityTag 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = {
  parent: transitStatusApi
  name: 'mobility'
  dependsOn: [
    mobilityTag
  ]
}

// Bike Rental API tagged with 'Mobility'

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

resource bikeRentalApiMobilityTag 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = {
  parent: bikeRentalApi
  name: 'mobility'
  dependsOn: [
    mobilityTag
  ]
}

// Trip Planning API tagged with 'Mobility' and 'Planning'

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

resource tripPlanningApiMobilityTag 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = {
  parent: tripPlanningApi
  name: 'mobility'
  dependsOn: [
    mobilityTag
  ]
}

resource tripPlanningApiPlanningTag 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = {
  parent: tripPlanningApi
  name: 'planning'
  dependsOn: [
    planningTag
  ]
}
