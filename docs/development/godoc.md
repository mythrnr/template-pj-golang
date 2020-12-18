# GoDoc

## 01. `GoDoc` を見る

- http://localhost/pkg/github.com/mythrnr/template-pj-golang/?m=all

```bash
make godoc
```

## 02. カバレッジを見る

- http://localhost/unit_tests/github.com/mythrnr/template-pj-golang/

```bash
# Nginx の再起動が必要な為, godoc も実行
make cover godoc
```

[←Back](../README.md)
