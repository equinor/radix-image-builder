FROM mcr.microsoft.com/azure-cli:2.38.0
RUN apk add uuidgen gettext --no-cache
WORKDIR /radix-image-builder/
COPY build_acr.sh build_acr.sh

RUN adduser -D -g '' -u 1000 radix-image-builder

ENV TENANT=3aa4a235-b6e2-48d5-9195-7fcf05b459b0 \
    AZURE_CREDENTIALS=/radix-image-builder/.azure/sp_credentials.json \
    DOCKER_REGISTRY=radixdev \
    DOCKER_FILE_NAME=Dockerfile \
    CONTEXT=./workspace/ \
    NO_PUSH=""

RUN chmod +x /radix-image-builder/build_acr.sh
USER 1000
ENTRYPOINT [ "/radix-image-builder/build_acr.sh"]
CMD ["-c"]