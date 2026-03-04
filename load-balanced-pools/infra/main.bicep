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
    currentRegionSettings: primaryRegionSettings
    otherRegionSettings: secondaryRegionSettings
  }
}

module applicationInSecondaryRegion 'modules/application.bicep' = {
  scope: resourceGroup(secondaryRegionSettings.resourceGroupName)
  params: {
    currentRegionSettings: secondaryRegionSettings
    otherRegionSettings: primaryRegionSettings
  }
}
