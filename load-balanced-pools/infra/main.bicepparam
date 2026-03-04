using 'main.bicep'

param primaryRegionSettings = {
  location: 'swedencentral'
  resourceGroupName: 'rg-primary-sdc-orfff'
  apiManagementServiceName: 'apim-primary-sdc-orfff'
  functionAppName: 'func-primary-sdc-orfff'
  isPrimaryRegion: true
}

param secondaryRegionSettings = {
  location: 'norwayeast'
  resourceGroupName: 'rg-secondary-nwe-g5bv4'
  apiManagementServiceName: 'apim-secondary-nwe-g5bv4'
  functionAppName: 'func-secondary-nwe-g5bv4'
  isPrimaryRegion: false
}
