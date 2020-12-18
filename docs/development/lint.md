# Lintによる解析

- [GolangCI-Lint](https://github.com/golangci/golangci-lint) による解析を行い, コードの品質を保つ
- `Visual Studio Code` を使用している場合は保存時に解析処理が走る

## 01. 手動で Lint を実行する

```bash
make lint
```

### 対象を指定して実行

- `lint_target` に指定したディレクトリが対象となる.
- 再帰的に実行したい場合は `dir/...` のように指定する.

```
make lint lint_target=internal/usecase/...
```

[←Back](../README.md)
