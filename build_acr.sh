#!/bin/bash
function GetBuildCommand() {
  local prefix="BUILD_SECRET_"
  local buildArgs=''
  local ACR_TASK_NAME='radix-image-builder'
  echo "REMOTE_CONTEXT=${REMOTE_CONTEXT}"
  if [[ "${NO_PUSH}" != "--no-push" ]];
    PUSH="--push"
  fi
  CACHE_DISABLED=true
  if [[ "${CACHE_DISABLED}" == true ]]; then
    CACHE="--no-cache"
  else
    CACHE_TO_OPTIONS="--cache-to=type=registry,ref=${AZ_RESOURCE_CONTAINER_REGISTRY}/${REPOSITORY_NAME}:radix-cache-${BRANCH},mode=max"
  fi

  local buildCommand="az acr task run \
        --name ${ACR_TASK_NAME} \
        --registry ${AZ_RESOURCE_CONTAINER_REGISTRY} \
        --context ${CONTEXT} \
        --file ${CONTEXT}${DOCKER_FILE_NAME} \
        --set REPOSITORY_NAME=${REPOSITORY_NAME} \
        --set BRANCH=${BRANCH} \
        --set TAG=${TAG} \
        --set CLUSTER_TYPE=${CLUSTER_TYPE} \
        --set CLUSTER_NAME=${CLUSTER_NAME} \
        --set DOCKER_FILE_NAME=${DOCKER_FILE_NAME} \
        --set BUILD_ARGS=${BUILD_ARGS} \
        --set PUSH=${PUSH} \
        --set CACHE=${CACHE} \
        --set CACHE_TO_OPTIONS=${CACHE_TO_OPTIONS}"

  if [[ -n "${SUBSCRIPTION_ID}" ]]; then
    buildCommand+=" --subscription ${SUBSCRIPTION_ID} "
  fi
  local line
  local keyValue
  local envBuildSecret
  local secretName
  local secretValue

  while read -r line; do
      if [[ "$line" ]]; then
          keyValue=(${line//=/ })
          envBuildSecret=${keyValue[0]}
          secretName=${envBuildSecret#"$prefix"}
          secretValue="$(printenv $envBuildSecret | base64 | tr -d \\n)"

          buildArgs+="--build-arg $secretName=\"$secretValue\" "
      fi
  done <<< "$(env | grep 'BUILD_SECRET_')"

  if [[ -n "${RADIX_GIT_COMMIT_HASH}" ]]; then
    buildArgs+="--build-arg RADIX_GIT_COMMIT_HASH=\"${RADIX_GIT_COMMIT_HASH}\" "
  fi
  if [[ -n "${RADIX_GIT_TAGS}" ]]; then
    buildArgs+="--build-arg RADIX_GIT_TAGS=\"\\\"${RADIX_GIT_TAGS}\\\"\" "
  fi
  if [[ -n "${BRANCH}" ]]; then
    buildArgs+="--build-arg BRANCH=\"${BRANCH}\" "
  fi
  if [[ -n "${TARGET_ENVIRONMENTS}" ]]; then
    buildArgs+="--build-arg TARGET_ENVIRONMENTS=\"${TARGET_ENVIRONMENTS}\" "
  fi

  buildCommand+=" --set BUILD_ARGS=\"${buildArgs}\""
  echo "$buildCommand"
}

if [[ -z "${SP_USER}" ]]; then
  SP_USER=$(cat ${AZURE_CREDENTIALS} | jq -r '.id')
fi
if [[ -z "${SP_SECRET}" ]]; then
  SP_SECRET=$(cat ${AZURE_CREDENTIALS} | jq -r '.password')
fi
azBuildCommand="$(GetBuildCommand)"
az login --service-principal -u ${SP_USER} -p ${SP_SECRET} --tenant ${TENANT}
bash -c "$azBuildCommand"
