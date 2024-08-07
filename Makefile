.PHONY: test build run-test-image
build:
	docker buildx build --platform linux/arm64 -t radixdev.azurecr.io/radix-image-builder:dev .

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
		-e BRANCH=main \
		-e RADIX_ZONE=dev \
		-e TARGET_ENVIRONMENTS=dev,qa \
		radixdev.azurecr.io/radix-image-builder:dev
	rm ./test/credentials.json

push-dev:
	docker push radixdev.azurecr.io/radix-image-builder:dev

run-test-image:
	docker run radixdev.azurecr.io/radix-image-builder-test:1

deploy: build push-dev