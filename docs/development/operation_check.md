# ローカルの動作確認

## 01. サーバー起動

- 以降, 全てサーバーを起動した状態での確認

```bash
make serve
```

## 02. API の確認

- API: https://localhost/ping
- API Doc: https://localhost/openapi

## Ex. 開発環境の証明書有効化

- 開発環境は SSL 接続だが, 証明書が無効な為ブラウザでエラーを手動で回避しなければならない.  
  証明書を自分で信頼させることでこれを回避可能
- Mac の場合, `docker/nginx/certs/server.crt` を Keychain で信頼することで回避可能.

[←Back](../README.md)
