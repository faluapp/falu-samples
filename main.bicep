@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the resources')
param name string = 'falu-samples'

var managedIdentityName = name
var hostingPlanName = name
var storageAccountName = replace(name, '-', '')
var pythonAppName = '${name}-python'

/* Managed Identity */
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true // https://github.com/Azure/bicep/discussions/7029
  }
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource pythonAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: pythonAppName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource pythonApp 'Microsoft.Web/sites@2022-03-01' = {
  name: pythonAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: pythonAppInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: pythonAppInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(pythonAppName)
        }
        {
          name: 'FALU_API_KEY'
          value: '#{FALU_API_SECRET_KEY}#'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      linuxFxVersion: 'Python|3.9'
    }
    clientAffinityEnabled: false
    httpsOnly: true
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': { /*ttk bug*/}
    }
  }
  tags: {
    'hidden-link: /app-insights-resource-id': pythonAppInsights.id
  }
}

output pythonAppDefaultHostName string = pythonApp.properties.defaultHostName
