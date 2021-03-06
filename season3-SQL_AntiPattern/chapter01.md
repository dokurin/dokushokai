# 第1章 ジェイクウォーク

| -      | -                   |
|:-------|:--------------------|
| タイトル   | 製品に新しいアカウントを登録できなくなった                    |
| 起票日 | 令和元年 五月 三〇日 |
| 起票者 | @yoshioH         |
| 機能   |                     |

## 現象と期待動作
製品には最大5名のアカウントを所属させることができなければいけないが、5名登録できない場合がある。  

### 再現手順
1. アカウントを新規作成する
1. 製品に新規作成したアカウントを登録する
1. なお、既存のテストアカウントであれば問題なく登録できる

## 原因
現在、`Products`.`account_ids`にCSV形式でアカウントのリストが登録されている。このカラムがVARCHAR(64)で定義されているため、アカウントIDの桁数が繰り上がりに耐えられなかった。

かねてより、課題とされていた製品ごとの利用ユーザ数上限を設定できない問題もこれが原因である。

## 対処方法
施策の案として、以下の２つがある
1. 交差デーブル`Products_accounts`テーブルを新規に追加する
    - アカウントの
1. `account_ids`カラムのサイズを64バイトから1024に拡張する
    - プログラムの回収が発生しない
    - 紐づくアカウントの集計などの柔軟な対応がしにくい
    - システムのライフサイクルが終わりに近づいているのであればこちらを推奨する

## 施策
システムのライフサイクルが終わりに近づいているので、カラムサイズの拡張による暫定対応で突っ走る。

## 所感
ロックをかけて作業していなかったりするとヤバみ。