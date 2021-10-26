.PHONY: test build run-test-image
build:
	docker build -t radix-image-builder .

test:
	rm -f ./test/credentials.json
	az keyvault secret download --file ./test/credentials.json -n radix-cr-cicd-dev --vault-name radix-vault-dev
	docker run -it --rm \
		-v `pwd`/test:/workspace/ \
		-e AZURE_CREDENTIALS=/workspace/credentials.json \
		-e CONTEXT=/workspace/ \
		-e IMAGE=radixdev.azurecr.io/radix-image-builder-test:1 \
		-e CLUSTERTYPE_IMAGE=radixdev.azurecr.io/radix-image-builder-test:2 \
		-e CLUSTERNAME_IMAGE=radixdev.azurecr.io/radix-image-builder-test:3 \
		-e SUBSCRIPTION_ID=16ede44b-1f74-40a5-b428-46cca9a5741b \
		radix-image-builder
	rm ./test/credentials.json

run-test-image:
	docker run radixdev.azurecr.io/radix-image-builder-test:1