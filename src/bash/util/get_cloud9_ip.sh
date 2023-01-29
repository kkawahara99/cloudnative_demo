#!/bin/bash

# ------------------------------------------------------- #
# Cloud9で生成されたプライベートIPアドレスを取得する関数
# ------------------------------------------------------- #
function get_cloud9_ip() {
  # Cloud9環境名
  cloud9EnvName=aws-cloud9-${SYSTEM_NAME}-${ENV_NAME}-management-env

  echo "### getting Cloud9 IP ... ###"
  export CLOUD9_IP=$(
    aws ec2 describe-instances \
      --query "Reservations[].Instances[?contains(to_string(Tags),\`${cloud9EnvName}\`)].PrivateIpAddress" \
      --output text
  )
  echo "### complete getting Cloud9 IP ! ###"
}