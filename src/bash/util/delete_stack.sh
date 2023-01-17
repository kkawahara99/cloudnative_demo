#!/bin/bash

# ------------------------------------------------------- #
# スタック削除関数
# ------------------------------------------------------- #
function delete_stack() {
  # スタックID（stack-listから取得）
  stackId=$1
  # スタック名
  stackName=${SYSTEM_NAME}-${ENV_NAME}-stack-${stackId}

  echo "### deleting ${stackName} ... ###"
  aws cloudformation delete-stack \
    --stack-name ${stackName}
  aws cloudformation wait stack-delete-complete \
    --stack-name ${stackName}
  echo "### ${stackName} deleted! ###"
}