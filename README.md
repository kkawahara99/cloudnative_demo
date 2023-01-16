# cloud_native_demo
こちらの書籍のクラウドネイティブアプリケーション環境を
CloudFormationテンプレートベースで構築してみました。

『AWSで学ぶクラウドネイティブ実践入門』
https://www.impressrd.jp/news/detail/86

# 近況
2023/1/16

構築済み・・・VPC、ELB、WAF、ECR、Cloud9（使えるけど別途細工が必要）、VPCエンドポイント

未構築・・・ECS、Fargate、CICD周り

# 使い方

```
docker-compose up -d
docker-compose run --rm cloudnative_demo /bin/bash
docker-compose down --rmi all
```

```bash
./bash/dev_deploy.sh
```

```bash
git clone https://github.com/kkawahara99/cloudnative_demo.git
cd cloudnative_demo
ls -l
docker image build -t besudevdemo:v1 .
docker tag besudevdemo:v1 【アカウントID】.dkr.ecr.ap-northeast-1.amazonaws.com/besudevdemo:v1
aws configure list --profile c9_work
aws ecr get-login-password --region ap-northeast-1 --profile c9_work | docker login --username AWS --password-stdin 【アカウントID】.dkr.ecr.ap-northeast-1.amazonaws.com
docker push 【アカウントID】.dkr.ecr.ap-northeast-1.amazonaws.com/besudevdemo:v1
```
# 今後の課題
- 通信のSSL化
- セキュリティ的な観点でWAFの設定の見直し
- 一部ハードコード値のパラメータ化（Cidrブロックなど）
- Cloud9での管理ができるようにする
- 全スタック削除時にECRにイメージがあると削除できない
