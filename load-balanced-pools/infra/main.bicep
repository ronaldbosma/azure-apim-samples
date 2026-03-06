//=============================================================================
// Merge App Settings in the Site Config
//=============================================================================

targetScope = 'subscription'

//=============================================================================
// Parameters
//=============================================================================

@description('The name of the resource group in the first region')
param firstResourceGroupName string

@description('The name of the API Management service instance in the first region')
param firstApiManagementServiceName string

@description('The name of the Function App backend in the first region')
param firstFunctionAppName string

@description('The name of the resource group in the second region')
param secondResourceGroupName string

@description('The name of the API Management service instance in the second region')
param secondApiManagementServiceName string

@description('The name of the Function App backend in the second region')
param secondFunctionAppName string

//=============================================================================
// Resources
//=============================================================================

module applicationInPrimaryRegion 'modules/application.bicep' = {
  scope: resourceGroup(firstResourceGroupName)
  params: {
    apiManagementServiceName: firstApiManagementServiceName
    functionAppName: firstFunctionAppName
    otherFunctionAppResourceGroupName: secondResourceGroupName
    otherFunctionAppName: secondFunctionAppName
  }
}

module applicationInSecondaryRegion 'modules/application.bicep' = {
  scope: resourceGroup(secondResourceGroupName)
  params: {
    apiManagementServiceName: secondApiManagementServiceName
    functionAppName: secondFunctionAppName
    otherFunctionAppResourceGroupName: firstResourceGroupName
    otherFunctionAppName: firstFunctionAppName
  }
}
