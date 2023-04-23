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
  bucketName=${SYSTEM_NAME}-${ENV_NAME}-s3-deploy

  echo "### deploying ${stackName} ... ###"
  aws cloudformation deploy \
    --template-file ${templateFile} \
    --stack-name ${stackName} \
    --parameter-overrides `cat ${parameterFile}` \
      --capabilities CAPABILITY_NAMED_IAM
  # S3バケットが作成済かどうか判定（処理時間ロスのため保留）
  # cnt=`aws s3 ls | awk '{print $3}' | grep ${bucketName} | wc -l`
  # if [ $cnt -gt 0 ]; then
  #   # S3バケットが作成済の場合S3バケットにテンプレートアップロード
  #   aws cloudformation deploy \
  #     --s3-bucket ${bucketName} \
  #     --template-file ${templateFile} \
  #     --stack-name ${stackName} \
  #     --parameter-overrides `cat ${parameterFile}` \
  #     --capabilities CAPABILITY_NAMED_IAM
  # else
  #   # S3バケットが未作成の場合ローカルかテンプレート使用
  #   aws cloudformation deploy \
  #     --template-file ${templateFile} \
  #     --stack-name ${stackName} \
  #     --parameter-overrides `cat ${parameterFile}` \
  #     --capabilities CAPABILITY_NAMED_IAM
  # fi
  echo "### ${stackName} deployed! ###"
}