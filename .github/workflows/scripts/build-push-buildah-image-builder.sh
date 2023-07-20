#!/bin/bash
image_tag=${ACR_NAME}.azurecr.io/${CLASSIC_BUILDER_IMAGE_NAME}:${GITHUB_REF_NAME}-latest
context="${GITHUB_WORKSPACE}/buildah-image-builder"
az acr task run \
    --subscription ${AZURE_SUBSCRIPTION_ID} \
    --name radix-image-builder-internal \
    --registry ${ACR_NAME} \
    --context $context \
    --file $context/Dockerfile \
    --set DOCKER_REGISTRY=${ACR_NAME} \
    --set BRANCH=${GITHUB_REF_NAME} \
    --set TAGS="--tag ${image_tag}" \
    --set DOCKER_FILE_NAME=Dockerfile \
    --set PUSH="--push" \
    --set REPOSITORY_NAME=${CLASSIC_BUILDER_IMAGE_NAME} \
    --set CACHE="" \
    --set CACHE_TO_OPTIONS="--cache-to=type=registry,ref=${ACR_NAME}.azurecr.io/${CLASSIC_BUILDER_IMAGE_NAME}:radix-cache-${GITHUB_REF_NAME},mode=max"