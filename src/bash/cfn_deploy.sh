#!/bin/bash -eu

# ------------------------------------------------------- #
# ログ管理
# ------------------------------------------------------- #
LOG_OUT=./stdout.log
LOG_ERR=./stderr.log
exec 1> >(
  while read -r l; do echo "[$(date +"%Y-%m-%d %H:%M:%S")] $l"; done \
    | tee -a $LOG_OUT
)
exec 2>>$LOG_ERR

# ------------------------------------------------------- #
# 引数チェック
# ------------------------------------------------------- #
if [ $# != 2 ]; then
    echo 引数エラー: $* 1>&2
    exit 1
fi

# ------------------------------------------------------- #
# 変数定義
# ------------------------------------------------------- #
export SYSTEM_NAME=$1
export ENV_NAME=$2
export STACK_LIST=./stack-list

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

# ------------------------------------------------------- #
# Cloud9で生成されたSecurityGroupを取得する関数
# ------------------------------------------------------- #
function get_cloud9_sg() {
  echo "### getting Cloud9 SG ... ###"
  export CLOUD9_SG=$(
    aws ec2 describe-security-groups \
    --query "SecurityGroups[?contains(GroupName,\`aws-cloud9-${SYSTEM_NAME}-${ENV_NAME}-management-env\`)].GroupId" \
    --output text
  )
  echo "### complete getting Cloud9 SG ! ###"
}

# ------------------------------------------------------- #
# Cloud9で生成されたSecurityGroupをパラメータファイルに適用する関数
# ------------------------------------------------------- #
function apply_cloud9_sg() {
  # スタックID（stack-listから取得）
  stackId=$1
  # パラメータファイル
  parameterFile=../cloudformation/parameters/${ENV_NAME}/${stackId}.properties

  echo "### applying Cloud9 SG ... ###"
  sed -i -e "s/SgIdCloud9=.*/SgIdCloud9=${CLOUD9_SG}/g" ${parameterFile}
  echo "### complete applying Cloud9 SG ! ###"
}

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# stack-listの上から順にスタックをデプロイする
# ------------------------------------------------------- #
for line in `echo "$(cat stack-list)"`
do
  # Cloud9のSGをパラメータファイルに適用
  if test $line = "06-vpce" ; then
    apply_cloud9_sg $line
  fi

  # デプロイ
  deploy_stack $line

  # Cloud9のSGを取得
  if test $line = "05-cloud9" ; then
    get_cloud9_sg
  fi
done

exit