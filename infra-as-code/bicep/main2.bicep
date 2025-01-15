@description('The location in which all resources should be deployed.')
param location string = resourceGroup().location

@description('This is the base name for each Azure resource name (6-8 chars)')
@minLength(6)
@maxLength(8)
param baseName string

@description('Assign your user some roles to support fluid access when working in the Azure AI Foundry portal')
@maxLength(36)
@minLength(36)
param yourPrincipalId string


// Deploy Azure Key Vault 
module keyVaultModule 'keyvault2.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    location: location
    baseName: baseName
    yourPrincipalId: yourPrincipalId
  }
}
