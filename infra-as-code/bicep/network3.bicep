@description('The resource group location')
param vnet1 string


@description('The resource group location')
param vnet2 string


resource vnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  name: '${vnet1}-to-${vnet2}-peering'
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnet2)
    }
  }
}

resource vnetPeeringReverse 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  name: '${vnet2}-to-${vnet1}-peering'
  properties: {
    allowVirtualNetworkAccess: true
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnet1)
    }
  }
}
