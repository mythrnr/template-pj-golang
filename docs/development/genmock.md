# モック作成

## 01. モック生成

- 下記コマンドにより, interface 定義から自動で生成させる

```bash
make mock
```

### 対象を指定して実行

- `pkg` に指定したディレクトリ配下すべてが対象となる.

```bash
make mock pkg=apps
```

## 02. 外部パッケージのモックを作成する（例）

```bash
cd deployments

# Go標準パッケージの "net/http" の "RoundTripper" をモックする
mockery \
    --case=underscore \
    --dir=/usr/local/go/src/net/http \
    --name=RoundTripper \
    --output=net/http/client/mocks \
    --outpkg=mocks
```

[←Back](../README.md)
