# ローカルの動作確認

## 01. サーバー起動

```bash
make serve
```

## 02. 開発環境の証明書有効化

- 開発環境は SSL 接続だが, 証明書が無効な為ブラウザでエラーを手動で回避しなければならない.  
証明書を自分で信頼させることでこれを回避可能

### Docker コンテナ内から証明書をコピーする方法

```bash
cd deployments

docker-compose up
docker cp mythrnr-template-pj-golang_web_1:/etc/nginx/template-pj-golang.crt ${任意の場所}
```

[←Back](../README.md)
