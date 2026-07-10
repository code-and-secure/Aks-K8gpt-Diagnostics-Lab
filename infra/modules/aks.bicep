// infra/modules/aks.bicep
// Single-node AKS cluster, Free tier control plane (no SLA, no charge),
// sized to keep worker-node cost as low as possible for practice.

param location string
param projectName string
param nodeVmSize string
param kubernetesVersion string

var clusterName = 'aks-${projectName}'
var dnsPrefix = toLower('${projectName}-dns')

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: empty(kubernetesVersion) ? null : kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 1
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        osDiskSizeGB: 30
        // Keep this a single node with no autoscale to avoid surprise costs.
        enableAutoScaling: false
      }
    ]
    networkProfile: {
      networkPlugin: 'kubenet'
    }
  }
}

output clusterName string = aksCluster.name
output clusterId string = aksCluster.id
