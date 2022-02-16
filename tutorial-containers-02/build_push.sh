#!/usr/bin/env bash
# Should be run from the folder `tutorial-containers-02`
# You can get the login URI and credentials from: Portal -> ACR -> Access keys
REGISTRY_USERNAME=tutorialcontainers
REGISTRY_PASSWORD=<secret>
REGISTRY_ADDRESS=tutorialcontainers.azurecr.io

docker login ${REGISTRY_ADDRESS} --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD

# Build, tag, push
IMAGE_NAME=led-acr
IMAGE_VERSION=1.0
DOCKERFILE_PATH=./container-led
docker build -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}
docker tag ${IMAGE_NAME} ${REGISTRY_ADDRESS}/${IMAGE_NAME}:${IMAGE_VERSION}
docker push ${REGISTRY_ADDRESS}/${IMAGE_NAME}:${IMAGE_VERSION}

IMAGE_NAME=button-acr
IMAGE_VERSION=1.0
DOCKERFILE_PATH=./container-button
docker build -t ${IMAGE_NAME} -f ${DOCKERFILE_PATH}/Dockerfile ${DOCKERFILE_PATH}
docker tag ${IMAGE_NAME} ${REGISTRY_ADDRESS}/${IMAGE_NAME}:${IMAGE_VERSION}
docker push ${REGISTRY_ADDRESS}/${IMAGE_NAME}:${IMAGE_VERSION}