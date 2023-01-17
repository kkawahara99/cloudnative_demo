#!/bin/bash
# 実行shファイルをカレントディレクトリに変更
# （絶対パスで実行された場合への対応）
cd $(dirname $0)

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# ECS/Faregteアーキテクチャを一気に構築する為のシェルドライバ
# ①システム名（SYSTEM_NAME）を入力
# ②環境名（ENV_NAME）を入力
# ③構築するか、壊すかを選択（1:構築/2:破壊）
# ④"### End deploying ECS/Fargate ####"と出力されるまで待つ
# ------------------------------------------------------- #
# ①システム名（SYSTEM_NAME）を入力
echo -n "SYSTEM_NAME: "
read str
SYSTEM_NAME=$str
# ②環境名（ENV_NAME）を入力
echo -n "ENV_NAME: "
read str
ENV_NAME=$str
# ③構築するか、壊すかを選択（1:構築/2:破壊）
echo -n "Select mode [1:Deploy / 2:Cleanup]: "
read num
if [ "$num" == "1" ]; then
    echo "### Start deploying ECS/Fargate ###"
    ./cfn_deploy.sh $SYSTEM_NAME $ENV_NAME
    echo "### End deploying ECS/Fargate ###"
elif [ "$num" == "2" ]; then
    echo -n "本当に削除してもよろしいですか？ [Y/n]: "
    read str
    case $str in
        [yY]*)
            echo "### Start deleting ECS/Fargate ###"
            ./cfn_cleanup.sh $SYSTEM_NAME $ENV_NAME
            echo "### End deleting ECS/Fargate ###"
            ;;
        *) 
            ;;
    esac
else
    echo "'1'か'2'を入力してください"
    exit 1
fi

exit