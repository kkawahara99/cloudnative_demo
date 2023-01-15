#!/bin/bash
# 実行shファイルをカレントディレクトリに変更
# （絶対パスで実行された場合への対応）
cd $(dirname $0)

# ------------------------------------------------------- #
# Main
# ------------------------------------------------------- #
# 説明：
# cfn_cleanup.sh を実行する
# システム名は besu
# 環境名は dev（開発環境）
# ------------------------------------------------------- #
./cfn_cleanup.sh besu dev

exit