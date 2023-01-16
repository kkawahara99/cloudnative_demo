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
  # Cloud9環境名
  cloud9EnvName=aws-cloud9-${SYSTEM_NAME}-${ENV_NAME}-management-env

  echo "### getting Cloud9 SG ... ###"
  export CLOUD9_SG=$(
    aws ec2 describe-security-groups \
      --query "SecurityGroups[?contains(GroupName,\`${cloud9EnvName}\`)].GroupId" \
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
# Cloud9で生成されたEC2にIAMロールを付与する関数
# ------------------------------------------------------- #
function grant_cloud9_role() {
  # Cloud9環境名
  cloud9EnvName=aws-cloud9-${SYSTEM_NAME}-${ENV_NAME}-management-env
  # IAMロール名
  roleName=${SYSTEM_NAME}-${ENV_NAME}-cloud9-role

  echo "### granting Cloud9 IAM Role ... ###"
  # IAMプロファイル取得
  iamInstanceProfile=$(
    aws ec2 describe-instances \
      --query "Reservations[].Instances[?contains(to_string(Tags),\`${cloud9EnvName}\`)].IamInstanceProfile" \
      --output text
  )

  if [ "None" = "${iamInstanceProfile}" ]; then
    # Cloud9で生成されたEC2のインスタンスID取得
    instanceId=$(
      aws ec2 describe-instances \
        --query "Reservations[].Instances[?contains(to_string(Tags),\`${cloud9EnvName}\`)].InstanceId" \
        --output text
    )
    # EC2にIAMロールが付与されていないときのみ付与
    aws ec2 associate-iam-instance-profile \
      --instance-id ${instanceId} \
      --iam-instance-profile Name=${roleName}
  fi
  echo "### complete granting Cloud9 IAM Role ! ###"
}

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# stack-listの上から順にスタックをデプロイする
# ------------------------------------------------------- #
for line in `echo "$(cat ${STACK_LIST})"`
do
  # 06-vpceスタックデプロイ前の特別処理
  if test $line = "06-vpce" ; then
    apply_cloud9_sg $line
  fi

  # デプロイ
  deploy_stack $line

  # 05-cloud9スタックデプロイ後の特別処理
  if test $line = "05-cloud9" ; then
    get_cloud9_sg
    grant_cloud9_role
  fi
done

exit