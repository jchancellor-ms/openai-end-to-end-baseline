/*
  Deploy Key Vault with private endpoint and private DNS zone
*/

@description('This is the base name for each Azure resource name (6-8 chars)')
@minLength(6)
@maxLength(8)
param baseName string

@description('The resource group location')
param location string = resourceGroup().location


@description('Assign your user some roles to support fluid access when working in the Azure AI Foundry portal')
@maxLength(36)
@minLength(36)
param yourPrincipalId string

//variables
var keyVaultName = 'kv-${baseName}-1'

// ---- Existing resources ----

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    //networkAcls: {
    //  defaultAction: 'Deny'
    //  bypass: 'AzureServices' // Required for AppGW communication
    // }
    publicNetworkAccess: 'Enabled'

    tenantId: subscription().tenantId

    enableRbacAuthorization: true       // Using RBAC
    enabledForDeployment: true          // VMs can retrieve certificates
    enabledForTemplateDeployment: true  // ARM can retrieve values
    enabledForDiskEncryption: false

    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    createMode: 'default'               // Creating or updating the Key Vault (not recovering)
  }
}



//create role assignment for deployment user on the key vault with key vault administrator
resource keyVaultAdminUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, keyVault.id, 'keyVaultRoleAssignment')
  scope: keyVault
  properties: {
    principalId: deployer().objectId
    roleDefinitionId: keyVaultAdminUserRole.id // Key Vault Administrator
  }
}

resource keyVaultRoleAssignmentLabUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId, keyVault.id, 'keyVaultRoleAssignmentLabUser')
  scope: keyVault
  properties: {
    principalId: yourPrincipalId
    roleDefinitionId: keyVaultAdminUserRole.id // Key Vault Administrator
  }
}


@description('The name of the Key Vault.')
output keyVaultName string = keyVault.name
