#!/bin/bash
function GetBuildCommand() {
  local prefix="BUILD_SECRET_"
  local buildArgs=''
  local ACR_TASK_NAME=''
  if [[ "${NO_PUSH}" == "--no-push" ]]; then
    ACR_TASK_NAME="radix-image-builder-no-push"
  else
    ACR_TASK_NAME="radix-image-builder"
  fi

  local buildCommand="az acr task run \
    --name ${ACR_TASK_NAME} \
    --registry ${DOCKER_REGISTRY} \
    --context ${CONTEXT} \
    --file ${CONTEXT}${DOCKER_FILE_NAME} \
    --set IMAGE=${IMAGE} \
    --set CLUSTERTYPE_IMAGE=${CLUSTERTYPE_IMAGE} \
    --set CLUSTERNAME_IMAGE=${CLUSTERNAME_IMAGE} \
    --set DOCKER_FILE_NAME=${DOCKER_FILE_NAME} \
    --set CONTEXT=${CONTEXT} "
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

          buildArgs+="--secret-arg $secretName=\"$secretValue\" "
      fi
  done <<< "$(env | grep 'BUILD_SECRET_')"

  if [[ -n "${BRANCH}" ]]; then
    buildArgs+="--arg BRANCH=\"${BRANCH}\" "
  fi
  if [[ -n "${TARGET_ENVIRONMENTS}" ]]; then
    buildArgs+="--arg TARGET_ENVIRONMENTS=\"${TARGET_ENVIRONMENTS}\" "
  fi

  buildCommand="$buildCommand $buildArgs"
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
