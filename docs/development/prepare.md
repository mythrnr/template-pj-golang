# 開発の準備

## 01. 開発に使用するツールのインストール

### 必須

- `Docker` , `Docker Compose v2` , `GolangCI-Lint` , `make` , `mockery`

```bash
brew install --cask docker

brew install \
  docker \
  golangci/tap/golangci-lint \
  make \
  mockery
```

### 推奨

- [Sequel Ace](https://sequel-ace.com) ... MySQL クライアント. `Sequel Pro` の後継的アプリ.  
- [Spotlight Studio](https://stoplight.io/studio/) ... OpenAPI ドキュメントを記述するツール
- [Visual Studio Code](https://code.visualstudio.com/) ... `.vscode/settings.json` の効果を利用するためにも使用を推奨

```bash
brew install --cask sequel-ace
brew install --cask stoplight-studio
brew install --cask visual-studio-code

code --install-extension "EditorConfig.EditorConfig"
code --install-extension "golang.go"
code --install-extension "redhat.vscode-yaml"
```

## 02. Githubへのアクセストークン設定

- [New personal access token](https://github.com/settings/tokens/new?scopes=repo)
  にアクセスしてトークンを取得（Scopeはそのままで良い）
- 下記のように `.netrc` を作成する

```bash
machine github.com
    login ${取得したトークン}
    password x-oauth-basic
```

[←Back](../README.md)
