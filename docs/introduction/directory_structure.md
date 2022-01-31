# ディレクトリ構成

## プロジェクトルート

```bash
template-pj-golang
├── .devcontainer  ... VSCode で Remote Container を使うための設定
├── .github        ... GitHub 関連の設定（ Workflow など）
├── .vscode        ... このプロジェクトで使用する VSCode の設定
├── cmds           ... 各コマンドを配置
├── config         ... アプリケーションの設定ファイル
├── docker         ... Docker の設定ファイル
├── docs           ... ドキュメント配置場所
├── http           ... HTTP 層の処理
├── integrate      ... 結合テスト配置場所
├── migration      ... DBのマイグレーション用ファイル
├── pkg            ... 汎用性のある処理を配置
├── repository     ... Repository 層の処理
├── scripts        ... 開発用の各種スクリプト
├── usecase        ... Usecase 層の処理
├── .editorconfig
├── .env           ... Docker Compose 用の .env ファイル
├── .gitignore
├── .golangci.yaml
├── .netrc.example
├── go.mod
├── go.sum
├── main.go        ... エントリポイント
├── Makefile
└── README.md
```

[←Back](../README.md)
