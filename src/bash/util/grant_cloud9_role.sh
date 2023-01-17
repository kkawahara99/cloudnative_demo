#!/bin/bash

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