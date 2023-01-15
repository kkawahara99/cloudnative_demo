# cloud_native_demo
こちらの書籍のクラウドネイティブアプリケーション環境を
CloudFormationテンプレートベースで構築してみました。

『AWSで学ぶクラウドネイティブ実践入門』
https://www.impressrd.jp/news/detail/86

# 近況
2023/1/15

構築済み・・・VPC、ELB、WAF、ECR、Cloud9(使えない)、VPCエンドポイント

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

# 今後の課題
- 通信のSSL化
- セキュリティ的な観点でWAFの設定の見直し
- 一部ハードコード値のパラメータ化（Cidrブロックなど）
- Cloud9での管理ができるようにする
