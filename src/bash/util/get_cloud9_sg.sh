#!/bin/bash

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