# radix-image-builder

The radix-image-builder gives radix-pipeline access to build the images using ACR build functionality.

Build is done using Github actions. There are secrets defined for the actions to be able to push to radixdev, radixprod and radixus. These are the corresponding credentials for radix-cr-cicd-dev and radix-cr-cicd-prod service accounts

[![Build Status](https://github.com/equinor/radix-image-builder/workflows/radix-image-builder-build/badge.svg)](https://github.com/equinor/radix-image-builder/actions?query=workflow%3Aradix-image-builder-build)

## Local testing

use Makefile to test locally

`make build` will build a new image of radix-image-builder and keep it locally

`make test` will test the local radix-image-builder image by building the Dockerfile under `.test` and push this image to `radixdev` container registry