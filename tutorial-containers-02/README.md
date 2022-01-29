# Code modifications
TODO

# Infra setup
portal -> iot hub -> create -> ...

# Container build
our containers won't build themselves when deploying, we need to build them beforehand and store their images somewhere. I'll store in Azure Container Registry (could be Docker Registry, AWS ECR, etc)


TODO: instructions to create ACR on portal
take the values Address, User Name, and Password

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



# Device enrollment
based on this documentation: https://docs.microsoft.com/en-us/azure/iot-edge/how-to-register-
device?view=iotedge-2020-11&tabs=azure-portal


configure on cloud:
1. portal -> select the created iothub -> IoT Edge -> Add Iot Edge Device
2. choose a descritive name (I chose dev-leonardo-01)
3. Authentication type: Symmetric key
4. auto generate keys: yes
5. Connect this device to an IoT hub: enable
6. save




Go back to "IoT Edge", select your device, copy the priamry connection string to be string to be used in the script

also, we have to install iot edge on the device and configure it so it can connect with IoT Hub on the cloud

```bash
# Change the value of this variable
connection_string="<enter-the-value>"

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

sudo echo -e "[provisioning]\nsource = \"manual\"\nconnection_string = \"${connection_string}\"" | sudo tee /etc/aziot/config.toml

sudo cat /etc/aziot/config.toml
# Expected ouput: file saved with proper content

sudo iotedge config apply
# Expected output: services with status "Started!" and "Done" in the end

# sudo systemctl restart iotedge
sudo chmod -R 777 /var/run/iotedge/
sudo iotedge system logs
sudo iotedge check
# Expected output: you will see a docker-related error before we setup the modules, and you may see some warning; That's ok

sudo iotedge list
# Expected output: will list 2 modules from Azure IoT + our modules
```

you may have to wait a few minutes to everything be configured, but soon you'll see on the portal your device with the status "417 -- The device's deployment configuration is not set"

# Module deployment

click Set Modules -> Add ->     IoT Edge module


name "button", image URI "tutorialcontainers.azurecr.io/button:latest"
create options for led:
```
{
"HostConfig": {
    "Privileged": true,
    "PortBindings": {
    "80/tcp": [
        {
        "HostPort": "80"
        }
    ]
    },
    "Devices": [
    {
        "PathOnHost": "/dev/i2c-1",
        "PathInContainer": "/dev/i2c-1",
        "CgroupPermissions": "mrw"
    }
    ]
}
}
```


for button:
```
{
"HostConfig": {
    "Privileged": true,
    "Devices": [
    {
        "PathOnHost": "/dev/i2c-1",
        "PathInContainer": "/dev/i2c-1",
        "CgroupPermissions": "mrw"
    }
    ]
}
}

```

May take a few minutes download and run the images. Just grap a coffe and wait :) 
