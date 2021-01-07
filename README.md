# action-lambda-python-zip

GitHub Action to make zip deployment to AWS Lambda with pip requirements in a separate layer and additional custom layers.

Forked from: [![GitHubActions](https://img.shields.io/badge/listed%20on-GitHubActions-blue.svg)](https://github.com/marketplace/actions/aws-lambda-zip-deploy-python)

## Description
This action automatically installs requirements, zips and deploys the code including the dependencies as a separate layer.

#### Python 3.7 is supported

### Pre-requisites
In order for the Action to have access to the code, you must use the `actions/checkout@master` job before it.

### File Structure
This example workflow assumes your `requirements.txt` is in the root directory and that your functions are in folders with their function name as the directory name. Custom layers are assumed to be in a directory that matches their `custom_layer_N_path` value.

The below workflow would publish code to layers (pip and any custom layers) and functions (first_function and second_function), and finally also attach the layers to those updated functions.


### Environment variables
Storing credentials as a Github secret is strongly recommended.

- **AWS Credentials**
    `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are required.

### Inputs
- `requirements_txt`
    The name/path for the `requirements.txt` file. Defaults to `requirements.txt`.
- `pip_layer_arn`
    The ARN for the Lambda layer the dependencies should be pushed to **without the version** (version will be automatically updated on AWS).
- `custom_layer_1_path`
    Something like a folder of `utils` which holds all your utility code.
- `custom_layer_1_arn`
    The ARN for the Lambda layer where this utility code will go.
- `custom_layer_2_path`
    Same as above if you need more layers.
- `custom_layer_2_arn`
    Same as above if you need more layers.
- `custom_layer_3_path`
    Same as above if you need more layers.
- `custom_layer_3_arn`
    Same as above if you need more layers.
- `custom_layer_4_path`
    Same as above if you need more layers.
- `custom_layer_4_arn`
    Same as above if you need more layers.
- `lambda_function_names`
    The Lambda function names comma separated.
- `aws_region`


### Example Workflow
```yaml
on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@master
    - name: Deploy code to Lambda
      uses: seattleagainstslavery/action-lambda-python-zip@v1.1
      with:
        pip_layer_arn: 'YOUR_UNIQUE_ARN:layer:LAYER_NAME'
        custom_layer_1_path: 'utils'
        custom_layer_1_arn: 'YOUR_UNIQUE_ARN:layer:LAYER_NAME'
        lambda_function_names: 'first_function,second_function'
        aws_region: 'us-east-2'
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
