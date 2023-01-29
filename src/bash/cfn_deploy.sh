#!/bin/bash -eu

# ------------------------------------------------------- #
# ログ管理
# ------------------------------------------------------- #
source ./util/log_manager.sh

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
# 関数インポート
# ------------------------------------------------------- #
source ./util/deploy_stack.sh
source ./util/get_cloud9_sg.sh
source ./util/get_cloud9_ip.sh
source ./util/apply_cloud9_props.sh
source ./util/grant_cloud9_role.sh
source ./util/put_containerInsights.sh

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# stack-listの上から順にスタックをデプロイする
# ------------------------------------------------------- #
for line in `echo "$(cat ${STACK_LIST})"`
do
  if [ $line = "06-vpce" ] ; then
    # 06-vpceスタックデプロイ前の特別処理
    apply_cloud9_props $line
  elif [ $line = "07-ecs" ] ; then
    # 07-ecsスタックデプロイ前の特別処理
    put_containerInsights 1
  fi

  # デプロイ
  deploy_stack $line

  # 05-cloud9スタックデプロイ後の特別処理
  if [ $line = "05-cloud9" ] ; then
    get_cloud9_sg
    get_cloud9_ip
    grant_cloud9_role
  fi
done

exit