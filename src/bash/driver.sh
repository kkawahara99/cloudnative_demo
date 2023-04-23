#!/bin/bash
# 実行shファイルをカレントディレクトリに変更
# （絶対パスで実行された場合への対応）
cd $(dirname $0)

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# CloudFormationテンプレートを一気に構築する為のシェルドライバ
# ①システム名（SYSTEM_NAME）を入力
# ②環境名（ENV_NAME）を入力
# ③構築するか、壊すかを選択（1:構築/2:破壊）
# ④"### End deploying システム名-環境名 ####"と出力されるまで待つ
# ------------------------------------------------------- #
# 引数が指定されている場合それらを使用
if [ $# == 3 ]; then
    SYSTEM_NAME=$1
    ENV_NAME=$2
    num=$3
elif [ $# == 2 ]; then
    SYSTEM_NAME=$1
    ENV_NAME=$2
elif [ $# == 1 ]; then
    SYSTEM_NAME=$1
elif [ $# -gt 3 ]; then
    echo "引数エラー"
    echo "usage: driver.sh [SYSTEM_NAME] [ENV_NAME] [mode 1:Deploy / 2:Cleanup]"
    exit 1
fi

# ①システム名（SYSTEM_NAME）を入力
if [ "$1" == "" ]; then
    echo -n "SYSTEM_NAME: "
    read str
    SYSTEM_NAME=$str
fi
# ②環境名（ENV_NAME）を入力
if [ "$2" == "" ]; then
    echo -n "ENV_NAME: "
    read str
    ENV_NAME=$str
fi
# ③構築するか、壊すかを選択（1:構築/2:破壊）
if [ "$3" == "" ]; then
    echo -n "Select mode [1:Deploy / 2:Cleanup]: "
    read num
fi

if [ "$num" == "1" ]; then
    echo "### Start deploying $SYSTEM_NAME-$ENV_NAME ###"
    ./cfn_deploy.sh $SYSTEM_NAME $ENV_NAME
    echo "### End deploying $SYSTEM_NAME-$ENV_NAME ###"
elif [ "$num" == "2" ]; then
    echo -n "本当に削除してもよろしいですか？ [Y/n]: "
    read str
    case $str in
        [yY]*)
            echo "### Start deleting $SYSTEM_NAME-$ENV_NAME ###"
            ./cfn_cleanup.sh $SYSTEM_NAME $ENV_NAME
            echo "### End deleting $SYSTEM_NAME-$ENV_NAME ###"
            ;;
        *) 
            ;;
    esac
else
    echo "'1'か'2'を入力してください"
    exit 1
fi

exit