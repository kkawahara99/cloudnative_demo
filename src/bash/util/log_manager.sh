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