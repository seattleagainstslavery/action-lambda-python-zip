#!/bin/bash

configure_aws_credentials(){
  aws configure set aws_access_key_id "${INPUT_AWS_ACCESS_KEY_ID}"
  aws configure set aws_secret_access_key "${INPUT_AWS_SECRET_ACCESS_KEY}"
  aws configure set default.region "${INPUT_AWS_REGION}"
  echo "REGION SET AS: ${INPUT_AWS_REGION}"
}

publish_pip_layer(){
  ALL_LAYERS_ARN_VERSION=()
  echo "Installing and zipping dependencies..."
  mkdir python
  pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
  zip -r dependencies.zip ./python
  echo "Publishing dependencies as a layer..."
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_PIP_LAYER_ARN}" --zip-file fileb://dependencies.zip)
  PIP_LAYER_VERSION=$(jq '.Version' <<< "$result")
  ALL_LAYERS_ARN_VERSION+="${INPUT_PIP_LAYER_ARN}:${PIP_LAYER_VERSION}"
  rm -rf python
  rm dependencies.zip
}

publish_custom_layers(){
  if [ -z ${INPUT_CUSTOM_LAYER_1_PATH} ]; then
    echo "custom_layer_1_path is not set"
  else
    echo "Publishing custom layer 1"
    mkdir python
    INIT_FILE=$INPUT_CUSTOM_LAYER_1_PATH/predeploy.sh
    if [ -f "$INIT_FILE" ]; then
        echo "$INIT_FILE exists."
        cd $INPUT_CUSTOM_LAYER_1_PATH
        ./predeploy.sh
        cd ..
    fi
    cp -r ${INPUT_CUSTOM_LAYER_1_PATH} python
    zip -r custom_layer_1.zip ./python
    local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_1_ARN}" --zip-file fileb://custom_layer_1.zip)
    CUSTOM_LAYER_1_VERSION=$(jq '.Version' <<< "$result")
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_CUSTOM_LAYER_1_ARN}:${CUSTOM_LAYER_1_VERSION}"
    rm -rf python
    rm custom_layer_1.zip
    rm -rf ${INPUT_CUSTOM_LAYER_1_PATH}
  fi

  if [ -z ${INPUT_CUSTOM_LAYER_2_PATH} ]; then
    echo "custom_layer_2_path is not set"
  else
    echo "Publishing custom layer 2"
    mkdir python
    INIT_FILE=$INPUT_CUSTOM_LAYER_2_PATH/predeploy.sh
    if [ -f "$INIT_FILE" ]; then
        echo "$INIT_FILE exists."
        cd $INPUT_CUSTOM_LAYER_2_PATH
        ./predeploy.sh
        cd ..
    fi
    cp -r ${INPUT_CUSTOM_LAYER_2_PATH} python
    zip -r custom_layer_2.zip ./python
    local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_2_ARN}" --zip-file fileb://custom_layer_2.zip)
    CUSTOM_LAYER_2_VERSION=$(jq '.Version' <<< "$result")
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_CUSTOM_LAYER_2_ARN}:${CUSTOM_LAYER_2_VERSION}"
    rm -rf python
    rm custom_layer_2.zip
    rm -rf ${INPUT_CUSTOM_LAYER_2_PATH}
  fi

  if [ -z ${INPUT_CUSTOM_LAYER_3_PATH} ]; then
    echo "custom_layer_3_path is not set"
  else
    echo "Publishing custom layer 3"
    mkdir python
    INIT_FILE=$INPUT_CUSTOM_LAYER_3_PATH/predeploy.sh
    if [ -f "$INIT_FILE" ]; then
        echo "$INIT_FILE exists."
        cd $INPUT_CUSTOM_LAYER_3_PATH
        ./predeploy.sh
        cd ..
    fi
    cp -r ${INPUT_CUSTOM_LAYER_3_PATH} python
    zip -r custom_layer_3.zip ./python
    local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_3_ARN}" --zip-file fileb://custom_layer_3.zip)
    CUSTOM_LAYER_3_VERSION=$(jq '.Version' <<< "$result")
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_CUSTOM_LAYER_3_ARN}:${CUSTOM_LAYER_3_VERSION}"
    rm -rf python
    rm custom_layer_3.zip
    rm -rf ${INPUT_CUSTOM_LAYER_3_PATH}
  fi

  if [ -z ${INPUT_CUSTOM_LAYER_4_PATH} ]; then
    echo "custom_layer_4_path is not set"
  else
    echo "Publishing custom layer 4"
    mkdir python
    INIT_FILE=$INPUT_CUSTOM_LAYER_4_PATH/predeploy.sh
    if [ -f "$INIT_FILE" ]; then
        echo "$INIT_FILE exists."
        cd $INPUT_CUSTOM_LAYER_4_PATH
        ./predeploy.sh
        cd ..
    fi
    cp -r ${INPUT_CUSTOM_LAYER_4_PATH} python
    zip -r custom_layer_4.zip ./python
    local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_4_ARN}" --zip-file fileb://custom_layer_4.zip)
    CUSTOM_LAYER_4_VERSION=$(jq '.Version' <<< "$result")
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_CUSTOM_LAYER_4_ARN}:${CUSTOM_LAYER_4_VERSION}"
    rm -rf python
    rm custom_layer_4.zip
    rm -rf ${INPUT_CUSTOM_LAYER_4_PATH}
  fi
}

publish_public_layers(){
  if [ -z ${INPUT_PUBLIC_LAYER_1_ARN} ]; then
    echo "public_layer_1_arn is not set"
  else
    echo "Publishing public layer 1"
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_PUBLIC_LAYER_1_ARN}"
  fi

  if [ -z ${INPUT_PUBLIC_LAYER_2_ARN} ]; then
    echo "public_layer_1_arn is not set"
  else
    echo "Publishing public layer 1"
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_PUBLIC_LAYER_2_ARN}"
  fi

  if [ -z ${INPUT_PUBLIC_LAYER_3_ARN} ]; then
    echo "public_layer_1_arn is not set"
  else
    echo "Publishing public layer 1"
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_PUBLIC_LAYER_3_ARN}"
  fi

  if [ -z ${INPUT_PUBLIC_LAYER_4_ARN} ]; then
    echo "public_layer_1_arn is not set"
  else
    echo "Publishing public layer 1"
    ALL_LAYERS_ARN_VERSION+=" ${INPUT_PUBLIC_LAYER_4_ARN}"
  fi
}

# publish_function(){
#   echo "Deploying the code for ${1}"
#   # cd "${1}"
#   zip -r code.zip .
#   aws lambda update-function-code --function-name "${1}" --zip-file fileb://code.zip
#   rm code.zip
#   # cd ..
# }

update_function_layers(){
  echo "Adding pip layer and custom layers to ${1}"
  echo ${ALL_LAYERS_ARN_VERSION[@]}
  aws lambda update-function-configuration --function-name "${1}" --layers ${ALL_LAYERS_ARN_VERSION[@]}
}

deploy_lambda_function(){
  configure_aws_credentials
  publish_pip_layer
  publish_custom_layers
  publish_public_layers

  functionNames=(${INPUT_LAMBDA_FUNCTION_NAMES//,/ })
  zip -r code.zip .
  for name in ${functionNames[@]}; do
    echo "Deploying the code for ${1}"
    aws lambda update-function-code --function-name "${1}" --zip-file fileb://code.zip
    # publish_function $name
    update_function_layers $name
  done
  rm code.zip
}

deploy_lambda_function
echo "Each step completed, check the logs if any error occurred."
