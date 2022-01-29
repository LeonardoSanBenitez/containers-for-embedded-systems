managing deployments with Azure Iot Edge

the only change in the code was that I changed the container name from "led" to "led-acr" (to avoid conflicts if you have done the first part of this tutorial).

# Infra setup
portal -> iot hub -> create -> ...

# Container build
our containers won't build themselves when deploying, we need to build them beforehand and store their images somewhere. I'll store in Azure Container Registry (could be Docker Registry, AWS ECR, etc)


TODO: instructions to create ACR on portal
take note of the values Address, User Name, and Password

as we are using ARM32 images, the easier way to build this images is in a ARM32 device (in our jetson)

change REGISTRY_USERNAME, REGISTRY_PASSWORD, and REGISTRY_ADDRESS to the values of your registry

The edge device will pull new images from the registry only when there is in the registry an image with higher version than the device have locally. Therefore, if you want to build different versions of your images, you need to change the IMAGE_VERSION variable (in the script) to indicate which should be downloaded be the edge device.

<build_push.sh>



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

<device_configuration.sh>



you may have to wait a few minutes to everything be configured, but soon you'll see on the portal your device with the status "417 -- The device's deployment configuration is not set"

# Module deployment

click Set Modules -> Add ->     IoT Edge module


for button:
name "button-acr", image URI "tutorialcontainers.azurecr.io/button-acr:1.0"
Container Create Options:
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

for led:
name "led-acr", image URI "tutorialcontainers.azurecr.io/led-acr:1.0"
Container Create Options:
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
review and create -> create


May take a few minutes download and run the images. Just grap a coffe and wait :) 



Now you have all containers running correctly.
What is the difference?
* you can see the logs in the Portal
* you can change the modules in the cloud, without having to login into the device

We didn't made any change in the code itself of the containers, but now we have access to Azure Iot Edge funcionallities, like communication between modules and between devices using azure's messaging mecanism.
