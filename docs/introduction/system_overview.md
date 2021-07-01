# システム構成

## 01. アーキテクチャ概要

- クリーンアーキテクチャとドメイン駆動設計に基づく実装

![クラス図](./classes.png)

## 02. Domain 層

### Entities

- 値オブジェクトの定義と業務知識を表現する.
- 値オブジェクト, 集約オブジェクトパッケージ: `internal/apps/*/domain`

## 03. Usecase 層

- パッケージ: `internal/apps/*/usecase`

### Input Boundary

- ユースケースの定義を記述する.
- インターフェイスの定義のみを記述する.

### Input Data

- `Input Boundary` の処理のパラメータオブジェクトの定義.
- バリデーション処理のみ記述する.

### Output Boundary

- 出力処理の定義を記述する.
- インターフェイスの定義のみを記述する.

### Output Data

- `Output Boundary` の処理のパラメータオブジェクトの定義.
- 表示に必要なデータのみを渡すようにするため, この時点で各値は汎化しておく.

### Use Case Interactor

- `Input Boundary` の実装.
- 業務の手続きのロジックを記述.

### Data Access Interface

- 外部データアクセス処理の定義.
- パラメータオブジェクトもここで定義.

## 04. Infrastructure 層

### Controller

- パッケージ: `internal/apps/http/handler`
- リクエストをユースケースの `Input Data` に変換し, 処理を呼び出す.

### Presenter

- パッケージ: `internal/apps/http/presenter`
- `Output Boundary` の実装.
- ユースケースの処理結果をクライアントに表示する処理.

### View Model, View

- パッケージ: `internal/apps/http/view`
- HTML の配置場所: `internal/apps/http/view/html`

### Data Access, Database

- パッケージ: `internal/apps/*/repository`
- `Data Access Interface` の実装.
- データベースや外部 API へアクセスし, 読み取り, 書き出しを担う.

[←Back](../README.md)
