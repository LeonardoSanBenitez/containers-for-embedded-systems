# Streamline IoT projects with Infrastructure as Code

on the dev machine, install:

* azure cli
* terraform


we have to store the terraform state file somewhere, and I choose azure blob storage (could be AWS S3, Google Cloud Storage or even your local computer)

# What is infra as code

Transform manual proceadures into executable code




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




the device enrollment is still the same process as in the part 2 of this tutorial, please take a look there. We won't cover the enrollment automation, like using Device Provisioning Service (DPS) from Azure.


# Deployment template

describe the what modules should be deployed, in a similar way as docker-compose that we used in the first tutorial 





# CI/CD pipeline

building the containers

applying the deployment template

we'll use Azure Pipelines, that is part of the set of solutios called Azure Devops

TODO: how to create the azure devops environment; Ane, can you do this?


creation:
1. pipelines
1. new pipeline
1. where is your code: github
1. select the repository
1. You'll be redirected to github to approve the connection



## Pre build
module.json
this format is an informal standard of Azure IoT, but as we seen in the previous tutorial, you don't need to follow it.
we'll use the module's version to decide wether the containers should be build or not, so that we don't build the every container every time

but the pipeline has to "remember" if it has already build a container before, right? We'll use Pipeline Library to that

1. pipelines
2. library
3. create variable group
4. give it the name "Latest Image Versions"
5. Add two variables, "button_latest" and "led_latest", both with the value 1.0.0
6. Pipeline permissions
7. Select our pipeline
8. Give permissions to the pipeline to write the variables
    a. security
    b. give Administrator permission to the user "<project name> Build Service"


## Build

Setup connection with the container registry
1. settings
1. Service connections
1. New Service Connection
1. select Docker Registry
1. selec Azure Container Registry
1. select the subscription in which you created the registry, and then the registry itself
1. give it the name "acr connection"
1. Enable the option "grant access permission to all pipelines"



for this tutorial this was not required, but we decided to also build the images for several architectures
since we are just using a Jetson Nano, the only image that will really run is the arm64 one. If you are using a raspberry pi you can use the arm32 one, or even use the amd64 to test/debug the containers in your personal computer.


if you run the pipeline now (by commiting and pushing to the repository), you'll see that all containers are build. If you access the container registry, you'll see that the newly build images are already there

# References

https://docs.microsoft.com/en-us/azure/iot-edge/how-to-continuous-integration-continuous-deployment?view=iotedge-2020-11

IoT Edge CI/CD Deep Dive Resources: https://github.com/VSChina/azure-iot-edge-humidity-filter-module-sample