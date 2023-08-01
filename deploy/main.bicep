@description('Location for all resources.')
param location string = resourceGroup().location

@secure()
@description('The wildcard certificate in PEM format')
param certificateValue string = ''

@description('The tag of the container. E.g. 1.2.0')
param containerImageTag string = '#{DOCKERIMAGETAG}#'

var managedIdentityName = 'falu-samples'
var keyVaultName = 'falu-samples'
var appEnvironmentName = 'falu-samples'

var dnsSuffix = 'hst-smpls.falu.io'
var acrServerName = 'tingle${environment().suffixes.acrLoginServer}'

var appDefs = [
  { lang: 'python', name: 'identity-verification', env: [], port: 8000, cpu: '0.25', memory: '0.5Gi' }
  // { lang: 'python', name: 'identity-verification', env: [] }
  // { lang: 'csharp', name: 'identity-verification', env: [] }
  // { lang: 'node', name: 'identity-verification', env: [] }
  // { lang: 'java', name: 'identity-verification', env: [] }
]

/* Managed Identity */
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

/* Key Vault */
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: { name: 'standard', family: 'A' }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

/* Container App Environment */
resource appEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: appEnvironmentName
  location: location
  properties: {
    customDomainConfiguration: {
      dnsSuffix: dnsSuffix
      certificateValue: certificateValue
    }
  }
}

/* Container Apps */
resource apps 'Microsoft.App/containerApps@2022-10-01' = [for def in appDefs: {
  name: def.name
  location: location
  properties: {
    managedEnvironmentId: appEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: contains(def, 'port') ? def.port : 80
        traffic: [ { latestRevision: true, weight: 100 } ]
      }
      registries: [ { identity: managedIdentity.id, server: acrServerName } ]
      secrets: [
        { name: 'falu-secret-api-key', value: '#{FALU_API_SECRET_KEY}#' }
        { name: 'python-secret-key', value: uniqueString(resourceGroup().id) }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrServerName}/falu/samples/${def.name}:${containerImageTag}'
          name: def.name
          env: concat(
            def.lang == 'python' ? [
              { name: 'SECRET_KEY', secretRef: 'python-secret-key' }
              { name: 'FALU_API_KEY', secretRef: 'falu-secret-api-key' }
            ] : [],
            def.lang == 'dotnet' ? [
              { name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED', value: 'true' }
              { name: 'Falu__ApiKey', secretRef: 'falu-secret-api-key' }
            ] : [],
            def.env)
          resources: {
            cpu: json(contains(def, 'cpu') ? def.cpu : '0.25')
            memory: contains(def, 'memory') ? def.memory : '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {/*ttk bug*/ }
    }
  }
}]

output endpoints array = [for index in range(0, length(appDefs)): 'https://${apps[index].name}.${dnsSuffix}']
