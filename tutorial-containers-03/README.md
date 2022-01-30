on the dev machine, install:
* azure cli
* azure-iot
* terraform


we have to store the terraform state file somewhere, and I choose azure blob storage (could be AWS S3, Google Cloud Storage or even your local computer)

# Code modifications
TODO

# Infra setup

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

# Device enrollment

we'll use a service called "Device Provisioning Service", that ease this process a little, but there still be manual tasks involved

We'll use the mode "individual enrollment", since we only have one device, but we could chose the option "group enrollment" and with basically the same steps manage thousands of devices at the same time.

the creation of new enrollments in DPS cannot be done with terraform (yet), and we'll use azure cli again

```bash
az iot dps enrollment-group create \
    --resource-group tutorial-containers \
    --dps-name tutorialcontainers \
    --enrollment-id device-dev-01 \
    --edge-enabled true  \
    --initial-twin-tags "{ 'tags': { 'stage': 'dev' }, 'properties': { 'desired': {} } }"  \
    --reprovision-policy reprovisionandmigratedata \
    --provisioning-status enabled


echo "-----------------"
echo "-- Enrollment info:"

az iot dps enrollment-group show \
    --dps-name tutorialcontainers \
    --enrollment-id device-dev-01 \
    --resource-group tutorial-containers
```


TODO DONT KNOW IF WORKS: how to get the SCOPE_ID and PRIMARY_KEY via CLI?
or get the data from Portal, in:

also, we have to install iot edge on the device and configure it so it can connect with IoT Hub on the cloud

```bash
# Change the value of this variable
SCOPE_ID=<enter-the-value>
REGISTRATION_ID=<enter-the-value>
PRIMARY_KEY=<enter-the-value>

########################################
# Paste all commands bellow, one by one
# Please check the outputs for errors
# If your password is requested, please enter it (you won’t see the letters filling in the screen)
sudo apt-get update -y && sudo apt install -y curl nano

curl https://packages.microsoft.com/config/ubuntu/18.04/multiarch/prod.list > ./microsoft-prod.list

sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg

sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/

sudo apt-get update -y && sudo apt-get install -y aziot-edge

keybytes=$(echo $PRIMARY_KEY | base64 --decode | xxd -p -u -c 1000)

DERIVED_KEY=$(echo -n $REGISTRATION_ID | openssl sha256 -mac HMAC -macopt hexkey:$keybytes -binary | base64)

sudo cp /etc/aziot/config.toml.edge.template /etc/aziot/config.toml

sudo echo -e "[provisioning]\nsource = \"dps\"\nglobal_endpoint = \"https://global.azure-devices-provisioning.net\"\nid_scope = \"${SCOPE_ID}\"\n[provisioning.attestation]\nmethod =\"symmetric_key\"\nregistration_id = \"${REGISTRATION_ID}\"\nsymmetric_key = { value = \"${DERIVED_KEY}\"}\n" | sudo tee /etc/aziot/config.toml

sudo cat /etc/aziot/config.toml
# Expected ouput: file saved with proper content

sudo iotedge config apply
# Expected output: services with status "Started!" and "Done" in the end

# sudo systemctl restart iotedge
sudo iotedge system logs
sudo iotedge check
# Expected output: you will see a docker-related error before we setup the modules, and you may see some warning; That's ok

sudo iotedge list
# Expected output: will list 2 modules from Azure IoT + our modules
```

as you can see, there are three values in the begining of the scrit that you have to fill: SCOPE_ID, REGISTRATION_ID and PRIMARY_KEY.

you have to take these values from the Azure Portal (or follow directly the [microsoft documentation](https://docs.microsoft.com/en-us/azure/iot-dps/quick-create-simulated-device-symm-key?pivots=programming-language-python)):



1. Access the Portal
2. Select "Device Provisioning Service"
3. Under "Overview", copy the value "ID Scope"
4. Select "Manage enrollments"
5. Select "+ Add individual enrollment"
    a. Select "symmetric key" as mechanism
    b. Check the box "Auto-generate keys"
    c. Chose a descriptive "Registration ID", for instance: "dev-leonardo-01". Copy this value.
    d. Leave "Device ID" blank
    e. Initial Device Twin State:
    ```json
    {
    "tags": {
        "stage": "dev"
    },
    "properties": {
        "desired": {}
    }
    }
    ```
    f. Save
6. Select the newly created device, under the "Individual Enrollments" tab
7. Copy the "primary key"




finally, you device should be ready to receive the modules

# Container build
our containers won't build themselves when deploying, we need to build them beforehand and store their images somewhere. I'll store in Azure Container Registry (could be Docker Registry, AWS ECR, etc)

as we are using ARM32 images, the easier way to build this images is in a ARM32 device (in our jetson)

```bash
# Should be run from the folder `tutorial-containers-02`
# You can get the login URI and credentials from: Portal -> ACR -> Access keys
REGISTRY_USERNAME=tutorialcontainers
REGISTRY_PASSWORD=<secret>
REGISTRY_ADDRESS=tutorialcontainers.azurecr.io

docker login ${REGISTRY_ADDRESS} --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD

# Build, tag, push
# TODO: manually manage versions
IMAGE_NAME=led
DOCKERFILE_PATH=./container-led
docker build -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}
docker tag ${IMAGE_NAME} ${REGISTRY_ADDRESS}/${IMAGE_NAME}
docker push ${REGISTRY_ADDRESS}/${IMAGE_NAME}

IMAGE_NAME=button
DOCKERFILE_PATH=./container-button
docker build -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}
docker tag ${IMAGE_NAME} ${REGISTRY_ADDRESS}/${IMAGE_NAME}
docker push ${REGISTRY_ADDRESS}/${IMAGE_NAME}
```

# Module deployment















execute `./.pipeline/templates/steps/deploy.yml` with the parameters:
  deploymentFile: deployment.template.nano.json
  device: nano
  platform: arm64v8


az iot edge deployment create \
--deployment-id tutorial-containers-deployment \
--hub-name tutorialcontainers \
--content ./deployment.json \
--target-condition "tags.stage='dev'" \
--priority 0 

az iot edge deployment create --deployment-id [deployment id] --hub-name [hub name] --content [file path] --labels "[labels]" --target-condition "[target query]" --priority [int]
