#!/bin/bash

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