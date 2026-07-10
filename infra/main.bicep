// infra/main.bicep
// Deploys a minimal, cost-conscious AKS cluster for practicing K8sGPT.
// Free-tier control plane + a single small B-series node.

targetScope = 'subscription'

@description('Short project name used as a prefix for all resources')
param projectName string = 'aksk8sgpt'

@description('Azure region for all resources')
param location string = 'eastus'

@description('Environment tag, e.g. dev, test')
param environment string = 'dev'

@description('VM size for the single system node. B2s is the cheapest widely-available size.')
param nodeVmSize string = 'Standard_B2s'

@description('Kubernetes version. Leave empty to use the region default.')
param kubernetesVersion string = ''

var resourceGroupName = 'rg-${projectName}-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

module aks 'modules/aks.bicep' = {
  name: 'aksDeploy'
  scope: rg
  params: {
    location: location
    projectName: projectName
    nodeVmSize: nodeVmSize
    kubernetesVersion: kubernetesVersion
  }
}

output resourceGroup string = resourceGroupName
output clusterName string = aks.outputs.clusterName
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${resourceGroupName} --name ${aks.outputs.clusterName}'
