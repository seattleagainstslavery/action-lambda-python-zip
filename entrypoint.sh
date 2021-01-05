#!/bin/bash

configure_aws_credentials(){
	aws configure set aws_access_key_id "${INPUT_AWS_ACCESS_KEY_ID}"
  aws configure set aws_secret_access_key "${INPUT_AWS_SECRET_ACCESS_KEY}"
  aws configure set default.region "${INPUT_LAMBDA_REGION}"
}

install_zip_dependencies(){
	echo "Installing and zipping dependencies..."
	mkdir python
	pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
	zip -r dependencies.zip ./python
}

publish_dependencies_as_layer(){
	echo "Publishing dependencies as a layer..."
  echo "${INPUT_PIP_LAYER_ARN}"
	local result=$(aws lambda publish-layer-version --layer-name "${INPUT_PIP_LAYER_ARN}" --zip-file fileb://dependencies.zip)
	LAYER_VERSION=$(jq '.Version' <<< "$result")
	rm -rf python
	rm dependencies.zip
}

publish_custom_layers(){
  echo "imagine I was publishing custom layers"
  echo "${INPUT_CUSTOM_LAYER_1_PATH}"
  echo "${INPUT_CUSTOM_LAYER_1_ARN}"
  echo "${INPUT_CUSTOM_LAYER_2_PATH}"
  echo "${INPUT_CUSTOM_LAYER_2_ARN}"
  echo "${INPUT_CUSTOM_LAYER_3_PATH}"
  echo "${INPUT_CUSTOM_LAYER_3_ARN}"
  echo "${INPUT_CUSTOM_LAYER_4_PATH}"
  echo "${INPUT_CUSTOM_LAYER_4_ARN}"
}

publish_functions(){
	echo "IMAGE THIS LOOPED USING each of the names"
  echo "${INPUT_LAMBDA_FUNCTION_NAMES}"

  echo "Deploying the code itself..."
	zip -r code.zip . -x \*.git\*
	aws lambda update-function-code --function-name "${INPUT_LAMBDA_FUNCTION_NAMES}" --zip-file fileb://code.zip
}

update_functions_layers(){
	echo "IMAGINE THIS LOOPED USING EACH OF THE FUNCTION NAMES AND WIRED UP ALL THE LAYERS"
  echo "${INPUT_LAMBDA_FUNCTION_NAMES}"

  echo "Using the layer in the function..."
	aws lambda update-function-configuration --function-name "${INPUT_LAMBDA_FUNCTION_NAMES}" --layers "${INPUT_LAMBDA_LAYER_ARN}:${LAYER_VERSION}"
}

deploy_lambda_function(){
  configure_aws_credentials
	install_zip_dependencies
	publish_dependencies_as_layer
  publish_custom_layers
	publish_functions
	update_functions_layers
}

deploy_lambda_function
echo "Each step completed, check the logs if any error occured."
