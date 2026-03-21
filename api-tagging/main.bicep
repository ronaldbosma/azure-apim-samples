//=============================================================================
// API Tagging sample in API Management
//=============================================================================

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the API Management service')
param apiManagementServiceName string

@description('Indicates whether to add operation-level tags from the OpenAPI definition to the API in API Management')
param addOperationLevelTagsToApi bool = false

//=============================================================================
// Variables
//=============================================================================

var apiTags = [
  'mobility'
  'public'
  'planning'
]

var transitStatusApiTags = ['mobility']

var bikeRentalApiOperationTags = addOperationLevelTagsToApi
  ? flatten(loadYamlContent('apis/bike-rental-api.openapi.yaml', '$.paths.*.*.tags'))
  : []
var bikeRentalApiTags = union(['mobility'], bikeRentalApiOperationTags)

var tripPlanningApiOpenApiContent = loadYamlContent('apis/trip-planning-api.openapi.yaml')
var tripPlanningApiOperationTags = addOperationLevelTagsToApi ? extractOperationTags(tripPlanningApiOpenApiContent) : []
var tripPlanningApiTags = union(['mobility', 'planning'], tripPlanningApiOperationTags)

//=============================================================================
// Existing resources
//=============================================================================

resource apiManagementService 'Microsoft.ApiManagement/service@2025-03-01-preview' existing = {
  name: apiManagementServiceName
}

//=============================================================================
// Functions
//=============================================================================

@description('Extract all operation-level tags from an OpenAPI specification')
func extractOperationTags(openApiContent object) array =>
  flatten(map(
    items(openApiContent.?paths ?? {}),
    pathItem => flatten(map(items(pathItem.value), operation => getOperationTags(operation.value)))
  ))

@description('Extract tags from an operation object, returning empty array if no tags exist')
func getOperationTags(operation object) array => operation.?tags ?? []

//=============================================================================
// Resources
//=============================================================================

// Tags

resource apimTags 'Microsoft.ApiManagement/service/tags@2025-03-01-preview' = [
  for tagName in apiTags: {
    parent: apiManagementService
    name: tagName
    properties: {
      displayName: tagName
    }
  }
]

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
  dependsOn: [
    apimTags
  ]
}

resource addTransitStatusApiTags 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = [
  for tagName in transitStatusApiTags: {
    parent: transitStatusApi
    name: tagName
    dependsOn: [
      apimTags
    ]
  }
]

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
  dependsOn: [
    apimTags
  ]
}

resource addBikeRentalApiTags 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = [
  for tagName in bikeRentalApiTags: {
    parent: bikeRentalApi
    name: tagName
    dependsOn: [
      apimTags
    ]
  }
]

// Trip Planning API tagged with 'Mobility' and 'Planning'

resource tripPlanningApi 'Microsoft.ApiManagement/service/apis@2025-03-01-preview' = {
  name: 'trip-planning'
  parent: apiManagementService
  properties: {
    displayName: 'Trip Planning API'
    path: 'trip-planning'
    format: 'openapi'
    value: string(tripPlanningApiOpenApiContent)
    type: 'http'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
  dependsOn: [
    apimTags
  ]
}

resource addTripPlanningApiTags 'Microsoft.ApiManagement/service/apis/tags@2025-03-01-preview' = [
  for tagName in tripPlanningApiTags: {
    parent: tripPlanningApi
    name: tagName
    dependsOn: [
      apimTags
    ]
  }
]
