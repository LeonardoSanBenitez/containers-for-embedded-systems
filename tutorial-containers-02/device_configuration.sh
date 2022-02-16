#!/usr/bin/env bash
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