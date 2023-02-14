# ディレクトリ構成

## プロジェクトルート

```bash
template-pj-golang
├── .devcontainer  ... VSCode で Remote Container を使うための設定
├── .github        ... GitHub 関連の設定（ Workflow など）
├── .vscode        ... このプロジェクトで使用する VSCode の設定
├── app            ... 各コマンドを配置
├── bin            ... 成果物のバイナリが出力される場所
├── config         ... アプリケーションの設定ファイル
├── docker         ... Docker の設定ファイル
├── docs           ... ドキュメント配置場所
├── featureXXX     ... 機能を実装する場所. 配下の `domain` と `usecase` はこの機能内で使用するもののみ
├── integrate      ... 結合テスト配置場所
├── migration      ... DBのマイグレーション用ファイル
├── repository     ... Repository 層の実装
├── scripts        ... 開発用の各種スクリプト
├── .editorconfig
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
