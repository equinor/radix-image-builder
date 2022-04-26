#!/bin/bash
image_tag=${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${GITHUB_REF_NAME}-latest
docker build . -t $image_tag
az acr login --name ${ACR_NAME}
docker push $image_tag