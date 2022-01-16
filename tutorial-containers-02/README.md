on the dev machine, install:
* azure cli
* terraform


we have to store the terraform state file somewhere, and I choose azure blob storage

basic setup:

```bash
#!/bin/bash
# You must be authenticated with az cli

# Variables
RESOURCE_GROUP_NAME=tutorial-terraform-backend
STORAGE_ACCOUNT_NAME=tutorialtfstate
CONTAINER_NAME=tfstate
LOCATION=EastUS

# Create resources
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME 
```

terraform init
terraform apply


unfortunatelly, the define enrollment cannot be dne with terraform, and we'll use azure cli again