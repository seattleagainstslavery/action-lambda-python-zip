#!/bin/bash

configure_aws_credentials(){
  aws configure set aws_access_key_id "${INPUT_AWS_ACCESS_KEY_ID}"
  aws configure set aws_secret_access_key "${INPUT_AWS_SECRET_ACCESS_KEY}"
  aws configure set default.region "${INPUT_AWS_REGION}"
}

install_zip_dependencies(){
  echo "Installing and zipping dependencies..."
  mkdir python
  pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
  zip -r dependencies.zip ./python
}

publish_dependencies_as_layer(){
  echo "Publishing dependencies as a layer..."
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_PIP_LAYER_ARN}" --zip-file fileb://dependencies.zip)
  PIP_LAYER_VERSION=$(jq '.Version' <<< "$result")
  rm -rf python
  rm dependencies.zip
}

publish_custom_layers(){
  echo "Publishing custom layer 1"
  zip -r custom_layer_1.zip "${INPUT_CUSTOM_LAYER_1_PATH}"
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_1_ARN}" --zip-file fileb://custom_layer_1.zip)
  CUSTOM_LAYER_1_VERSION=$(jq '.Version' <<< "$result")

  echo "Publishing custom layer 2"
  zip -r custom_layer_2.zip "${INPUT_CUSTOM_LAYER_2_PATH}"
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_2_ARN}" --zip-file fileb://custom_layer_2.zip)
  CUSTOM_LAYER_2_VERSION=$(jq '.Version' <<< "$result")

  echo "Publishing custom layer 3"
  zip -r custom_layer_3.zip "${INPUT_CUSTOM_LAYER_3_PATH}"
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_3_ARN}" --zip-file fileb://custom_layer_3.zip)
  CUSTOM_LAYER_3_VERSION=$(jq '.Version' <<< "$result")

  echo "Publishing custom layer 4"
  zip -r custom_layer_4.zip "${INPUT_CUSTOM_LAYER_4_PATH}"
  local result=$(aws lambda publish-layer-version --layer-name "${INPUT_CUSTOM_LAYER_4_ARN}" --zip-file fileb://custom_layer_4.zip)
  CUSTOM_LAYER_4_VERSION=$(jq '.Version' <<< "$result")
}

publish_function(){
  echo "Deploying the code for ${1}"
  zip -r "${1}".zip "${1}"
  aws lambda update-function-code --function-name "${1}" --zip-file fileb://"${1}".zip
}

update_function_layers(){
  echo "Adding pip layer and custom layers to ${1}"
  aws lambda update-function-configuration --function-name "${1}" --layers "${INPUT_PIP_LAYER_ARN}:${PIP_LAYER_VERSION}" "${INPUT_CUSTOM_LAYER_1_ARN}:${CUSTOM_LAYER_1_VERSION}" "${INPUT_CUSTOM_LAYER_2_ARN}:${CUSTOM_LAYER_2_VERSION}" "${INPUT_CUSTOM_LAYER_3_ARN}:${CUSTOM_LAYER_3_VERSION}" "${INPUT_CUSTOM_LAYER_4_ARN}:${CUSTOM_LAYER_4_VERSION}"
}

deploy_lambda_function(){
  configure_aws_credentials
  install_zip_dependencies
  publish_dependencies_as_layer
  publish_custom_layers

  functionNames=(${INPUT_LAMBDA_FUNCTION_NAMES//,/ })
  for name in ${functionNames[@]}; do
    publish_function name
    update_function_layers name
  done
}

deploy_lambda_function
echo "Each step completed, check the logs if any error occurred."
