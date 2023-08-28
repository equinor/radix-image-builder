#!/bin/bash
set -e
buildah login --username ${BUILDAH_USERNAME} --password ${BUILDAH_PASSWORD} ${DOCKER_REGISTRY}.azurecr.io
buildah build --storage-driver=vfs --isolation=chroot --jobs 0 \
        ${SECRET_ARGS} --file ${CONTEXT}${DOCKER_FILE_NAME} \
        --tag ${IMAGE} \
        --tag ${CLUSTERTYPE_IMAGE} \
        --tag ${CLUSTERNAME_IMAGE} \
        ${CONTEXT}
buildah push --storage-driver=vfs --all ${IMAGE}
# TODO: reset to correct git commit hash