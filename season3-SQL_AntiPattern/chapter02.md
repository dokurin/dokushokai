# 第２章 ナイーブツリー（素朴な木）

| タイトル | 起票日     | 起票者  | 機能 |
|:---------|:-----------|:--------|:-----|
|          | 2019/06/07 | @ryutah |      |

## 概要
RDBで稀によくある、「階層構造」を表現する場合のアンチパターンとその解決策を紹介

## アンチパターン
### 近接リスト
#### 定義例
#### どんなパターン？
* 親の階層のIDをカラムに持たせる

##### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  parent_id    BIGINT UNSIGNED, -- 親のcomment_idが設定される
  bug_id       BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME NOT NULL, 
  comment      TEXT NOT NULL,
  FOREIGN KEY (parent_id) REFERENCES Comments(comment_id),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
```

#### 問題点
* すべての子孫を取得するのが困難
* ノードの削除が難しい

#### その他
* WITH句で再帰クエリの実現ができるようになったそうなので割とありなパターンになってきたらしい


## 解決方法
### 経路列挙（Path Enumeration）
#### どんなパターン？
* 先祖の系譜を表す文字列を各ノードの属性として格納する

##### 例
<img width="240" alt="68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f31393137352f38646565303166382d636337642d303963392d636636662d6130316639336365353933362e706e67" src="https://user-images.githubusercontent.com/6662577/59142441-493b5d00-89f9-11e9-9008-2eee15b16504.png">

#### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  path         VARCHAR(1000), -- 経路パスを保存するカラム
  bug_id       BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME NOT NULL,
  comment      TEXT NOT NULL,
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
```

#### 感想
* データ構造が単純なので階層構造を考えるときにとりあえず最初に試してみるパターンだったりする
* 子孫データを見るだけで親データにどういうものがあるのかや、そのノードがどういう階層にあるデータかがわかるのが好き
* 外部キー制約で経路の正当性を保証することはできないため、アプリケーションのバグなどで階層構造がぶっ壊れる

---

### 入れ子集合（Nested Set）
#### どんなパターン？
* 子孫集合に関する情報を各ノードに格納する

##### イメージ
![002](https://user-images.githubusercontent.com/6662577/59142317-450e4000-89f7-11e9-86d4-23777513e52a.jpg)

#### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  nsleft       INTEGER NOT NULL, -- 左端の値
  nsright      INTEGER NOT NULL, -- 右端の値
  bug_id       BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME NOT NULL,
  comment      TEXT NOT NULL,
  FOREIGN KEY (bug_id) REFERENCES Bugs (bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
```

#### 感想
* 有名なパターンだと思うけど個人的に嫌い
* データ単体でみたときにそれがどういう階層のデータなのかイメージできない
* ノードが追加されるたびに再計算が必要になるからうっとおしい
* 理論的には理解できるんだけど、実際問題このパターンを適用してアプリケーションの仕組みが単純になると思えない

---

### 開包テーブル（Closure Table）
#### どんなパターン？
* ツリー全体のパスを保存するテーブルを追加する

##### 例
###### 階層構造を持つデータ
![68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f3235343733312f62303734663264362d336231352d323762622d306337322d6431376431366463363665652e706e67](https://user-images.githubusercontent.com/6662577/59142522-8ce29680-89fa-11e9-83d7-bf886baf3138.png)

###### 開包テーブル
![68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f3235343733312f62626139663762342d373332372d326265662d356334302d3165323039666531653865312e706e67](https://user-images.githubusercontent.com/6662577/59142542-cca97e00-89fa-11e9-989b-071c25c09e70.png)

#### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  bug_id       BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME NOT NULL,
  comment      TEXT NOT NULL,
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);

-- 経路パスを保存するテーブル
CREATE TABLE TreePaths (
  ancestor    BIGINT UNSIGNED NOT NULL,
  descendant  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (ancestor, descendant),
  FOREIGN KEY (ancestor) REFERENCES Comments(comment_id),
  FOREIGN KEY (descendant) REFERENCES Comments(comment_id)
);
```

#### 感想
* ちゃんとやるならこれ
* 仕組みも単純だし各種操作も簡単
* 外部キー制約でのデータ正当性保証も問題なし
* 追加のテーブルが必要になるのが唯一のデメリットだけど大した問題じゃないと思う


## まとめ
* 階層構造問題は、RDBを使ってると一度は直面する代表的なもので、初めて扱うとアンチパターンとして紹介される近接リストを使いがちなため、覚えておいて損はないと思う
* 個人的おすすめ度
  - 開包テーブル > 経路パス >>>>>>>>>>>>>>>> 入れ子集合


## 補足
### WITH句を使った再帰クエリ構文を試してみた
#### サンプルテーブル定義
```sql
CREATE TABLE `division` (
  id        int(10) unsigned NOT NULL,
  name      varchar(50) DEFAULT NULL,
  parent_id int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `division_idfk_1` (`parent_id`),
  CONSTRAINT `division_idfk_1` FOREIGN KEY (`parent_id`) REFERENCES `division` (`id`)
)
```

#### データ例
```txt
+----+-----------------------------------+-----------+
| id | name                              | parent_id |
+----+-----------------------------------+-----------+
|  1 | 社長                              |      NULL |
|  2 | 役員会                            |         1 |
|  3 | コンプライアンス委員会            |         2 |
|  4 | 管理本部                          |         1 |
+----+-----------------------------------+-----------+
```

#### クエリと結果
```sql
WITH recursive divison_tree(id, name, parent_id, depth) AS(
  SELECT
    *,
    0 AS DEPTH
  FROM
    division
  WHERE
    parent_id IS NULL
  UNION ALL
  SELECT
    d.*,
    dt.depth + 1 AS depth
  FROM
    divison_tree dt
    INNER JOIN
      division AS d
    ON  dt.id = d.parent_id
)
SELECT
  *
FROM
  divison_tree
WHERE
  id = 3;

+------+-----------------------------------+-----------+-------+
| id   | name                              | parent_id | depth |
+------+-----------------------------------+-----------+-------+
|    3 | コンプライアンス委員会            |         2 |     2 |
+------+-----------------------------------+-----------+-------+
```

#### Explain結果
```sql
+----+-------------+------------+------------+------+-----------------+-----------------+---------+-------+------+----------+------------------------+
| id | select_type | table      | partitions | type | possible_keys   | key             | key_len | ref   | rows | filtered | Extra                  |
+----+-------------+------------+------------+------+-----------------+-----------------+---------+-------+------+----------+------------------------+
|  1 | PRIMARY     | <derived2> | NULL       | ref  | <auto_key0>     | <auto_key0>     | 5       | const |    1 |   100.00 | NULL                   |
|  2 | DERIVED     | division   | NULL       | ref  | division_idfk_1 | division_idfk_1 | 5       | const |    1 |   100.00 | Using index condition  |
|  3 | UNION       | dt         | NULL       | ALL  | NULL            | NULL            | NULL    | NULL  |    2 |   100.00 | Recursive; Using where |
|  3 | UNION       | d          | NULL       | ref  | division_idfk_1 | division_idfk_1 | 5       | dt.id |    1 |   100.00 | NULL                   |
+----+-------------+------------+------------+------+-----------------+-----------------+---------+-------+------+----------+------------------------+
```

#### 感想
* フルテーブルスキャン発生してるし普通に遅そうだなぁと思った（小並）
