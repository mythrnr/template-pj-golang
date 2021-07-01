# ディレクトリ構成

## プロジェクトルート

- [Standard Go Project Layout](https://github.com/golang-standards/project-layout) を参考に構成

```bash
template-pj-golang
├── .github        ... GitHub 関連の設定（ Workflow など）
├── .vscode        ... このプロジェクトで使用する VSCode の設定
├── build          ... 開発用 Docker 等のファイル
├── cmd            ... 各 main.go が配置されるエントリポイント
├── configs        ... 設定ファイル群
├── deployments    ... デプロイやローカル動作に関わる設定ファイル
├── docs           ... ドキュメント配置場所
├── integrate      ... 結合テスト配置場所
├── internal       ... 内部処理群
├── scripts        ... 開発用の各種スクリプト
├── .editorconfig
├── .gitignore
├── .golangci.yml
├── .netrc.example
├── doc.go         ... 設定ファイルやバージョン情報の埋め込み用ファイル
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

## `internal` ディレクトリ（例）

```bash
template-pj-golang/internal
├── apps    ... 機能を関心ごとに分離して配置する
├── builder ... 依存解決など, template-pj-golang/cmd で呼び出すためのメインアプリを構築する
├── http    ... HTTP の共通処理
└── mysql   ... MySQL の共通処理
```

## `internal/apps/*` ディレクトリ（例）

```bash
internal/apps/*
├── context ... コンテキストオブジェクトとの値のやり取りに使用する
├── domain  ... ドメインモデルや Value Object を配置
├── http
│    ├── handler     ... リクエストを usecase に渡す処理
│    ├── presenter   ... レスポンスの整形
│    └── route       ... ルーティングの定義
├── repository        ... 外部データの取得・保存の実装
│    └── persistence ... 永続化処理の実装（主にDB）
└── usecase           ... 各ユースケース処理を配置
```

[←Back](../README.md)
