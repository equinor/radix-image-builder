[![Build Status](https://github.com/equinor/radix-image-builder/workflows/radix-image-builder-build/badge.svg)](https://github.com/equinor/radix-image-builder/actions?query=workflow%3Aradix-image-builder-build)
# radix-image-builder

The radix-image-builder gives radix-pipeline access to build the images using ACR build functionality.

Build and push to container registry is done using Github actions. 

## Local testing

use Makefile to test locally

`make build` will build a new image of radix-image-builder and keep it locally

`make test` will test the local radix-image-builder image by building the Dockerfile under `.test` and push this image to `radixdev` container registry

## Contribution

Want to contribute? Read our [contributing guidelines](./CONTRIBUTING.md)

## Security

This is how we handle [security issues](./SECURITY.md)
