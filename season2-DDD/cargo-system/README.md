# 貨物輸送システムサンプルアプリケーション
## ビジネス要件
* 顧客貨物に対する主要な荷役を追跡できる
* あらかじめ貨物を予約できる
* 貨物が荷役の過程で所定の場所に到達した際に、自動的に請求書を顧客に送付する


## システムユースケース図
### 貨物予約
![usecase1](docs/usecase/usecase.png)
### 荷役
![usecase2](docs/usecase/usecase_001.png)
### 問い合わせ
![usecase3](docs/usecase/usecase_002.png)


## 補足事項
### 顧客の種類
* 荷物を送る人
* 荷物を受け取る人
* 支払いをする人

### 荷役
* 貨物の積み込みや荷下ろし、あるいは倉庫・ヤード等への入庫・出庫を総称した作業

### 制限事項
* 発注者 1 -- N 受取者
* 貨物の積載制限などは考えない
* 責任の移動

```text
| Sender |                  | Receiver |
    + ----- | Transport | ----- +
```

* スケジュールのチェックなどは運用回避とする


## 用語集
### Customer
* 発注者
* 受取人

### User(Service Provider)
* サービスプロバイダ

### Cargo Transport System(CTS)
* システム化対象

#### Ordering Management Service(OMS)
* 受発注管理サービス
