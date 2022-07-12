#!/bin/bash
function GetBuildCommand() {
  local prefix="BUILD_SECRET_"
  local delimiter='\='
  local buildArgs=''

  local buildCommand="az acr build -t ${IMAGE} -t ${CLUSTERTYPE_IMAGE} -t ${CLUSTERNAME_IMAGE} ${NO_PUSH} -r ${DOCKER_REGISTRY} ${CONTEXT} -f ${CONTEXT}${DOCKER_FILE_NAME} "
  if [[ -n "${SUBSCRIPTION_ID}" ]]; then
    buildCommand+=" --subscription ${SUBSCRIPTION_ID} "
  fi
  local line
  local keyValue
  local envBuildSecret
  local secretName
  local secretValue
  
  if [[ -z "${BUILD_SECRET_RADIX_GIT_COMMIT_HASH}" ]]; then
    export RADIX_GIT_COMMIT_HASH=$(git --git-dir ${CONTEXT}.git rev-parse HEAD)
  else
    export RADIX_GIT_COMMIT_HASH=${BUILD_SECRET_RADIX_GIT_COMMIT_HASH}
  fi

  unset BUILD_SECRET_RADIX_GIT_COMMIT_HASH
  TEMP_RADIX_GIT_COMMIT_TAGS=$(git --git-dir ${CONTEXT}.git tag --points-at ${RADIX_GIT_COMMIT_HASH} 2>/dev/null | tr '\n' ' ' | xargs)

  while read -r line; do
      if [[ "$line" ]]; then
          keyValue=(${line//=/ })
          envBuildSecret=${keyValue[0]}
          secretName=${envBuildSecret#"$prefix"}
          secretValue="$(printenv $envBuildSecret | base64 | tr -d \\n)"

          buildArgs+="--secret-build-arg $secretName=\"$secretValue\" "
      fi
  done <<< "$(env | grep 'BUILD_SECRET_')"

  buildArgs+="--build-arg RADIX_GIT_COMMIT_HASH=\"${RADIX_GIT_COMMIT_HASH}\" "
  if [[ -z "${TEMP_RADIX_GIT_COMMIT_TAGS}" ]]; then
    buildArgs+="--build-arg RADIX_GIT_COMMIT_TAGS="
  else 
    buildArgs+="--build-arg RADIX_GIT_COMMIT_TAGS=\"\\\"(${TEMP_RADIX_GIT_COMMIT_TAGS})\\\"\" "
  fi

  if [[ -n "${BRANCH}" ]]; then
    buildArgs+="--build-arg BRANCH=\"${BRANCH}\" "
  fi
  if [[ -n "${TARGET_ENVIRONMENTS}" ]]; then
    buildArgs+="--build-arg TARGET_ENVIRONMENTS=\"${TARGET_ENVIRONMENTS}\" "
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