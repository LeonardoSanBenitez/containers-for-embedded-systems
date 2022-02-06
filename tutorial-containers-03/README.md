on the dev machine, install:
* azure cli
* terraform


we have to store the terraform state file somewhere, and I choose azure blob storage (could be AWS S3, Google Cloud Storage or even your local computer)

# What is infra as code

# Infrastructure provisioning

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




the device enrollment is still the same process as in the part 2 of this tutorial, please take a look there. We won't cover the enrollment automation, like using Device Provisioning Service from Azure.


# Deployment template

describe the what modules should be deployed, in a similar way as docker-compose that we used in the first tutorial 

# CI/CD pipeline

building the containers

applying the deployment template

we'll use Azure Pipelines, that is part of the set of solutios called Azure Devops

TODO: how to create the azure devops environment; Ane, can you do this?