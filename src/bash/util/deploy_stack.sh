#!/bin/bash

# ------------------------------------------------------- #
# スタックデプロイ関数
# ------------------------------------------------------- #
function deploy_stack() {
  # スタックID（stack-listから取得）
  stackId=$1
  # テンプレートファイル
  templateFile=../cloudformation/${stackId}.yaml
  # パラメータファイル
  parameterFile=../cloudformation/parameters/${ENV_NAME}/${stackId}.properties
  # スタック名
  stackName=${SYSTEM_NAME}-${ENV_NAME}-stack-${stackId}

  echo "### deploying ${stackName} ... ###"
  aws cloudformation deploy \
    --template-file ${templateFile} \
    --stack-name ${stackName} \
    --parameter-overrides `cat ${parameterFile}` \
    --capabilities CAPABILITY_NAMED_IAM
  echo "### ${stackName} deployed! ###"
}