//=============================================================================
// Merge App Settings in the Site Config
//=============================================================================

targetScope = 'subscription'

//=============================================================================
// Imports
//=============================================================================

import { regionalSettingsType } from './modules/types.bicep'

//=============================================================================
// Parameters
//=============================================================================

@description('The settings for the primary region')
param primaryRegionSettings regionalSettingsType

@description('The settings for the secondary region')
param secondaryRegionSettings regionalSettingsType

//=============================================================================
// Resources
//=============================================================================

module applicationInPrimaryRegion 'modules/application.bicep' = {
  scope: resourceGroup(primaryRegionSettings.resourceGroupName)
  params: {
    settings: primaryRegionSettings
    primaryFunctionAppName: primaryRegionSettings.functionAppName
    secondaryFunctionAppName: secondaryRegionSettings.functionAppName
  }
}

module applicationInSecondaryRegion 'modules/application.bicep' = {
  scope: resourceGroup(secondaryRegionSettings.resourceGroupName)
  params: {
    settings: secondaryRegionSettings
    primaryFunctionAppName: primaryRegionSettings.functionAppName
    secondaryFunctionAppName: secondaryRegionSettings.functionAppName
  }
}
