# Lintによる解析

- [GolangCI-Lint](https://github.com/golangci/golangci-lint) による解析を行い, コードの品質を保つ
- `Visual Studio Code` を使用している場合は保存時に解析処理が走る

## 01. 手動で Lint を実行する

```bash
make lint
```

### 対象を指定して実行

- `pkg` に指定したディレクトリ配下すべてが対象となる.

```bash
make lint pkg=internal/apps
```

[←Back](../README.md)
