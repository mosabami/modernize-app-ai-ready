You can find the bicep code in the iac folder.

You can convert the bicep code to arm by running 

```bash
az bicep build --file ./iac/azuredeploy.bicep
```

To deploy these resources needed to start the workshop run the commands below.

```bash
RGNAME=<your resource group name>
LOCATION=<your location>
cd iac
```

```bash
az group create -n $RGNAME -l $LOCATION
az deployment group create --resource-group $RGNAME --template-file azuredeploy.bicep --parameters @azuredeploy.parameters.json
```

To begin the worksho,p head over to the [exercises](./exercises/ex-1) folder and start with [1-clone-repo.md](https://github.com/mosabami/modernize-app-ai-ready/blob/main/exercises/ex-1/1-clone-repo.md).
