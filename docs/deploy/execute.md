# デプロイ実行

- 実行のタイミングは制御したいので, あえて自動化しない.

## 01. GitHub 上のページから実行

- [Actions](https://github.com/mythrnr/template-pj-golang/actions) から実行
- パラメータを下記の通り指定する

| 名称 | キー |値 | 用途 |
| - | - | - | - |
| `Branch` | `ref` | `master` or `develop` | workflow で利用するブランチ |
| `Release Env` | `inputs.env` | `production` or `testing` | デプロイ先の環境. 本番 or 検証 |
| `Version` | `inputs.version` | `v20.08.0` , `v20.08.1-dev.0` など | リリースを行うバージョン |

## 02. [予備] CLI で実行

- GitHub Actions の `workflow_dispatch` を CLI で実行する
- 上記のパラメータを JSON で指定する

```bash
BRANCH="master or develop"
RELEASE_ENV="production or testing"
VERSION="v20.08.0"

WORKFLOW_ID=$(curl -sL https://$GITHUB_TOKEN@api.github.com/repos/mythrnr/template-pj-golang/actions/workflows | jq '.workflows[] | select(.path | contains("deploy")) | .id')

curl -vvv -X POST \
    -H "Authorization: token $GITHUB_TOKEN"
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/mythrnr/template-pj-golang/actions/workflows/$WORKFLOW_ID/dispatches" \
    -d "{ \"ref\": \"$BRANCH\", \"inputs\": { \"env\": \"$RELEASE_ENV\", \"version\": \"$VERSION\" } }"
```

[←Back](../README.md)
