on the dev machine, install:
* azure cli
* terraform


we have to store the terraform state file somewhere, and I choose azure blob storage (could be AWS S3, Google Cloud Storage or even your local computer)

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

```bash
az iot dps enrollment-group create \
    --resource-group tutorial-containers \
    --dps-name tutorialcontainers \
    --enrollment-id device-dev-01 \
    --edge-enabled true  \
    --initial-twin-tags "{ 'tags': { 'stage': 'dev' }, 'properties': { 'desired': {} } }"  \
    --reprovision-policy reprovisionandmigratedata \
    --provisioning-status enabled
```



our containers won't build themselves in the edge device, we need to build them beforehand and store their images somewhere. I'll store in Azure Container Registry (could be Docker Registry, AWS ECR, etc)

note that you'll have to 

```bash
# Should be run from the folder `tutorial-containers-02`
# You can get the login URI and credentials from: Portal -> ACR -> Access keys
REGISTRY_USERNAME=tutorialcontainers
REGISTRY_PASSWORD=6NGJF6TF36/fkNp/M5hpq=XEGpJbActw
REGISTRY_ADDRESS=tutorialcontainers.azurecr.io

docker login ${REGISTRY_ADDRESS} --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD

# Build, tag, push
IMAGE_NAME=led
DOCKERFILE_PATH=./container-led
docker build -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}
docker tag ${IMAGE_NAME} ${REGISTRY_ADDRESS}/${IMAGE_NAME}
docker push ${REGISTRY_ADDRESS}/${IMAGE_NAME}
```