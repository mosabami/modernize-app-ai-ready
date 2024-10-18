You can find the bicep code in the iac folder.

You can convert the bicep code to arm by running 

```bash
az bicep build --file ./iac/azuredeploy.bicep
```

To deploy these resources enter the following

```bash
RGNAME=<your resource group name>
LOCATION=<your location>
cd iac
```

```bash
az group create -n $RGNAME -l $LOCATION
az deployment group create --resource-group $RGNAME --template-file azuredeploy.bicep --parameters @azuredeploy.parameters.json
```