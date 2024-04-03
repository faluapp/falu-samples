@description('Location for all resources.')
param location string = resourceGroup().location

@description('The tag of the container. E.g. 1.2.0')
param containerImageTag string = '#{DOCKER_IMAGE_TAG}#'

@description('The suffix used to name the app as a reviewApp')
param reviewAppNameSuffix string = ''

var isReviewApp = reviewAppNameSuffix != null && !empty(reviewAppNameSuffix)
var managedIdentityName = 'falu-samples'
var keyVaultName = 'falu-samples'
var appEnvironmentName = 'falu-samples'

var dnsSuffix = 'hst-smpls.falu.io'

var appDefs = [
  { lang: 'python', name: 'identity-verification', env: [] }
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

  // secret backing the certificate maintained OOB by https://github.com/tinglesoftware/certificates
  resource cert 'secrets' existing = { name: 'star-hst-smpls-falu-io' }
}

/* Container App Environment */
resource appEnvironmentInstance 'Microsoft.App/managedEnvironments@2023-11-02-preview' = if (!isReviewApp) {
  name: appEnvironmentName
  location: location
  properties: {
    customDomainConfiguration: {
      certificateKeyVaultProperties: {
        keyVaultUrl: keyVault::cert.properties.secretUri
        identity: managedIdentity.id
      }
      dnsSuffix: dnsSuffix
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
        targetPort: def.lang == 'dotnet' ? 8080 : 8000
        traffic: [{ latestRevision: true, weight: 100 }]
        corsPolicy: {
          allowedMethods: [ 'GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE' ]
          allowedOrigins: [ '*' ]
          allowedHeaders: [ '*' ]
          exposeHeaders: [ '*' ]
          maxAge: 300 // 5 minutes in seconds
        }
      }
      secrets: [{ name: 'falu-secret-api-key', value: '#{FALU_API_SECRET_KEY}#' }]
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/faluapp/falu-samples/${def.name}:${containerImageTag}'
          name: def.name
          env: concat(
            [{ name: 'FALU_API_KEY', secretRef: 'falu-secret-api-key' }],
            def.lang == 'dotnet' ? [{ name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED', value: 'true' }] : [],
            def.env)
          resources: { cpu: json('0.25'), memory: '0.5Gi' } // these are the least resources we can provision
        }
      ]
      scale: { minReplicas: 0, maxReplicas: 1 }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {/*ttk bug*/ }
    }
  }
}]

/* Role Assignments */
resource keyVaultAdministratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managedIdentity.id, 'KeyVaultAdministrator')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output endpoints array = [for index in range(0, length(appDefs)): 'https://${apps[index].properties.configuration.ingress.fqdn}']
