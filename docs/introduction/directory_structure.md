# ディレクトリ構成

- [Standard Go Project Layout](https://github.com/golang-standards/project-layout) を参考に構成

```bash
template-pj-golang
├── .github       ... GitHub 関連の設定（ Workflow など）
├── .vscode       ... このプロジェクトで使用する VSCode の設定
├── bin           ... 成果物のバイナリ
├── build         ... 開発用 Docker 等のファイル
├── cmd           ... 各 main.go が配置されるエントリポイント
├── configs       ... 設定ファイル群
├── deployments   ... デプロイやローカル動作に関わる設定ファイル
├── docs          ... ドキュメント配置場所
├── integrate     ... 結合テスト配置場所
├── internal      ... 内部処理群
├── pkg           ... 共通処理. どこから呼ばれてもいいような処理を置く
├── scripts       ... 開発用の各種スクリプト
├── web           ... Web アプリ用ファイル配置場所
├── .editorconfig ... EditorConfig の設定
├── .gitignore
├── .golangci.yaml
├── .netrc.example ... .netrc のテンプレート
├── go.mod
├── go.sum
├── Makefile
├── package.go
└── README.md
```

[←Back](../README.md)
