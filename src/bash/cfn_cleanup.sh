#!/bin/bash

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

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# stack-listの下から順にスタックを削除する
# ------------------------------------------------------- #
for line in `echo "$(cat ${STACK_LIST})" | tac`
do
  delete_stack $line
done

exit