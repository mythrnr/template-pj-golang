# 開発の準備

## 01. 開発に使用するツールのインストール

### 必須

- `Docker` , `Docker Compose` , `GolangCI-Lint` , `make` , `mockery`

```bash
brew install \
  docker \
  docker-compose \
  golangci/tap/golangci-lint \
  make \
  mockery
```

### 推奨

- `Sequel Ace` ... MySQL クライアント. `Sequel Pro` の後継的アプリ.  
  [App Store](https://apps.apple.com/us/app/sequel-ace/id1518036000) からインストールする
- `Visual Studio Code` ... `.vscode/settings.json` の効果を利用するためにも使用を推奨
- 本体と必要な拡張機能は下記でインストール可能

```bash
brew cask install visual-studio-code

code --install-extension "EditorConfig.EditorConfig"
code --install-extension "golang.go"
code --install-extension "redhat.vscode-yaml"
```

## 02. Githubへのアクセストークン設定

- [New personal access token](https://github.com/settings/tokens/new?scopes=repo)
  にアクセスしてトークンを取得（Scopeはそのままで良い）
- 下記のように `.netrc` を配置する

```bash
echo "machine github.com" >> .netrc
echo "    login ${取得したトークン}" >> .netrc
echo "    password x-oauth-basic" >> .netrc
```

[←Back](../README.md)
