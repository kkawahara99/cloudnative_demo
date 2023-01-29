#!/bin/bash

# ------------------------------------------------------- #
# Cloud9のパラメータファイルを変更する関数
# ------------------------------------------------------- #
function apply_cloud9_props() {
  # スタックID（stack-listから取得）
  stackId=$1
  # パラメータファイル
  parameterFile=../cloudformation/parameters/${ENV_NAME}/${stackId}.properties

  echo "### applying Cloud9 properties ... ###"
  sed -i -e "s/SgIdCloud9=.*/SgIdCloud9=${CLOUD9_SG}/g" ${parameterFile}
  sed -i -e "s/PriIPCloud9=.*/PriIPCloud9=${CLOUD9_IP}/g" ${parameterFile}
  echo "### complete applying Cloud9 properties ! ###"
}