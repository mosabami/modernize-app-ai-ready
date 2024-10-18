@description('The name of the SQL logical server.')
// param serverName string = uniqueString('sql', resourceGroup().id)
param pgService string = '${resourcePrefix}${uniqueString(resourceGroup().id)}pg'

@description('The name of the SQL Database.')
param sqlDBName string = 'pycontosohotel'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'postgres'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string 

@description('resource prefix used to name several of the resources')
param resourcePrefix string = ''


resource pgsqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: pgService
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '16'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword

    network: {
      publicNetworkAccess: 'Enabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      iops: 120
      tier: 'P4'
      storageSizeGB: 32
      autoGrow: 'Disabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
  }
}

resource pgsqlFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-12-01-preview' = {
  parent: pgsqlServer
  name: 'AllowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}


resource pgsqlDB 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  parent: pgsqlServer
  name: sqlDBName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.UTF8'
  }
}

output connectionString string = 'host=${pgsqlServer.properties.fullyQualifiedDomainName};port=5432;database=${sqlDBName};user=${administratorLogin};password=${administratorLoginPassword};'

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}aiserv'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {}
    customSubDomainName: '${resourcePrefix}${uniqueString(resourceGroup().id)}'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
}

module registry 'br/public:avm/res/container-registry/registry:0.1.1' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}acr'
  params: {
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}acr'
    location: location
    acrAdminUserEnabled: true
    publicNetworkAccess: 'Enabled'
    acrSku: 'Basic'
  }
}

module vault 'br/public:avm/res/key-vault/vault:0.4.0' = {
  name:  '${resourcePrefix}${uniqueString(resourceGroup().id)}kv'
  params: {
    name:  '${resourcePrefix}${uniqueString(resourceGroup().id)}kv'
    enablePurgeProtection: false
    location: location
    sku: 'standard'
    enableVaultForDiskEncryption: true
  }
}

module cogservices 'br/public:avm/res/cognitive-services/account:0.8.0' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}aiservices'
  params: {
    // Required parameters
    kind: 'AIServices'
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}aiservices'
    location: location
    publicNetworkAccess: 'Enabled'
  }
}

module openaiservice 'br/public:avm/res/cognitive-services/account:0.8.0' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}openai'
  params: {
    kind: 'OpenAI'
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}openai'
    location: location
    publicNetworkAccess: 'Enabled'
    customSubDomainName: '${resourcePrefix}${uniqueString(resourceGroup().id)}openai'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    deployments: [
      {
        model: {
          format: 'OpenAI'
          name: 'gpt-4o'
          version: '2024-05-13'
        }
        name: 'gpt-4o'
        sku: {
          name: 'Standard'
          capacity:100
        }
      }
      {
        model: {
          format: 'OpenAI'
          name: 'text-embedding-ada-002'
          version: '2'
        }
        name: 'text-embedding-ada-002'
        sku: {
          name: 'Standard'
          capacity:100
        }
      }
    ]
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.8.2' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}sa'
  params: {
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}'
    allowBlobPublicAccess: true
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
  }
}

// resource brochuresContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
//   name: '${storageAccount.name}/default/brochures'
//   properties: {
//     publicAccess: 'Blob'
//   }
// }



module managedEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}acaenv'
  params: {
    // Required parameters
    logAnalyticsWorkspaceResourceId: laws.id
    name: 'amemin001'
    internal: false
    location:  location
    zoneRedundant: false
  }
}


resource laws 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  location: location
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}law'
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku:{
      name:'PerGB2018'
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: false
    }
  }
}
