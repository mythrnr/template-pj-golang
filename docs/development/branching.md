# ブランチについて

## ブランチの名称と用途について

| 名称 | 用途 |
| - | - |
| `master` | 本番環境動作用 |
| `develop` | 検証環境動作用 |
| `feature/${what to add}` | 機能追加用 |
| `fix/${what to fix}` | バグ修正用 |
| `hotfix/${what to fix}` | 緊急の修正用 |

```
master  --------------------------------------------->
          ＼                                 ↗
             ---> feature/update_api ---- PR
                        ↘
develop --------------------------------------------->
```

## `master` , `develop` について

- 直接コミットされることが無い.
- `master` は保護とし, Pull Request によってのみマージ可能.
- Push されると GitHub Actions により自動でテストが走る.
- リリースはこれらのブランチから作成.

## `feature` , `fix` について

- 機能追加, 不具合修正時の作業用.
- 作業ブランチでの確認後, `develop` にマージを行い, 検証環境に反映する.

## `hotfix` について

- 緊急の不具合修正時の作業用.
- 作業ブランチでの確認後 Pull Request を作成し, `master` にマージしてリリースを行ってよい.

[←Back](../README.md)
