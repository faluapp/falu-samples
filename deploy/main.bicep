@description('Location for all resources.')
param location string = resourceGroup().location

@secure()
@description('The wildcard certificate in PEM format')
param certificateValue string = ''

@description('The tag of the container. E.g. 1.2.0')
param containerImageTag string = '#{DOCKER_IMAGE_TAG}#'

@description('The suffix used to name the app as a reviewApp')
param reviewAppNameSuffix string = ''

var isReviewApp = reviewAppNameSuffix != null && !empty(reviewAppNameSuffix)
var managedIdentityName = 'falu-samples'
var keyVaultName = 'falu-samples'
var appEnvironmentName = 'falu-samples'

var dnsSuffix = 'hst-smpls.falu.io'
var acrServerName = '#{ACR_LOGIN_SERVER}#'

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
resource appEnvironmentInstance 'Microsoft.App/managedEnvironments@2022-10-01' = if (!isReviewApp) {
  name: appEnvironmentName
  location: location
  properties: {
    customDomainConfiguration: {
      dnsSuffix: dnsSuffix
      certificateValue: certificateValue
    }
  }
}
resource appEnvironmentRef 'Microsoft.App/managedEnvironments@2022-10-01' existing = if (isReviewApp) { name: appEnvironmentName }

/* Container Apps */
resource apps 'Microsoft.App/containerApps@2022-10-01' = [for def in appDefs: {
  name: '${def.name}${reviewAppNameSuffix}'
  location: location
  properties: {
    managedEnvironmentId: isReviewApp ? appEnvironmentRef.id : appEnvironmentInstance.id
    configuration: {
      ingress: {
        external: true
        targetPort: contains(def, 'port') ? def.port : 80
        traffic: [ { latestRevision: true, weight: 100 } ]
      }
      registries: [ { identity: managedIdentity.id, server: acrServerName } ]
      secrets: [
        { name: 'falu-secret-api-key', value: '#{FALU_API_SECRET_KEY}#' }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrServerName}/falu/samples/${def.name}:${containerImageTag}'
          name: def.name
          env: concat(
            def.lang == 'python' ? [
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
