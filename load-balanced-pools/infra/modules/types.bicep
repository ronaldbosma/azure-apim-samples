@description('The settings for a region')
@export()
type regionalSettingsType = {
  @description('The location of the region')
  location: string

  @description('The name of the resource group for the region')
  resourceGroupName: string

  @description('The name of the API Management service')
  apiManagementServiceName: string

  @description('The name of the Function App')
  functionAppName: string

  @description('Whether this region is the primary region')
  isPrimaryRegion: bool
}
