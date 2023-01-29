#!/bin/bash

# ------------------------------------------------------- #
# ECSのCloudWatch Container Insightsを有効化または無効化する関数
# ------------------------------------------------------- #
function put_containerInsights() {
  enabledFlg=$1
  val=""

  # 引数チェック
  if [ $enabledFlg != 1 ] && [ $enabledFlg != 2 ] ; then
    echo 引数エラー: $* 1>&2
    exit 1
  fi
  # 引数が1の場合有効化、2の場合無効化
  if [ $enabledFlg == 1 ] ; then
    val="enabled"
  elif [ $enabledFlg == 2 ] ; then
    val="disabled"
  fi
  echo "### puting Container Insights ${val} ... ###"
  # CloudWatch Container Insightsの設定変更
  aws ecs put-account-setting \
    --name "containerInsights" \
    --value "${val}"
  echo "### complete uting Container Insights ${val} ! ###"
}