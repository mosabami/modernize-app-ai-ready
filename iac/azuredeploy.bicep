@description('The name of the SQL logical server.')
// param serverName string = uniqueString('sql', resourceGroup().id)
param pgService string = '${resourcePrefix}${uniqueString(resourceGroup().id)}pg'

@description('The name of the SQL Database.')
param sqlDBName string = 'pycontosohotel'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'contosoadmin'

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

module searchService 'br/public:avm/res/search/search-service:0.7.2' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}search'
  params: {
    // Required parameters
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}search'
    // Non-required parameters
    location: 'eastus'
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http403'
      }
    }
    disableLocalAuth: false
    managedIdentities: {
      systemAssigned: true
    }
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
    disableLocalAuth: false
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
    publicNetworkAccess: 'Enabled'
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
  }
}



module managedEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}acaenv'
  params: {
    // Required parameters
    logAnalyticsWorkspaceResourceId: laws.id
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}acaenv'
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

module component 'br/public:avm/res/insights/component:0.4.1' = {
  name: '${resourcePrefix}${uniqueString(resourceGroup().id)}appin'
  params: {
    // Required parameters
    name: '${resourcePrefix}${uniqueString(resourceGroup().id)}appin'
    workspaceResourceId: laws.id
    // Non-required parameters
    location: location
  }
}
