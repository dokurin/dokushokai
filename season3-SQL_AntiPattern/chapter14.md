# 第１４章 アンビギュアスグループ（曖昧なグループ）
## 概要
ふぇぇ、最新のデータがうまく抽出できないよぉ。。。

### サンプルデータ
#### Products
| product_id | product_name        |
|------------|---------------------|
| 1          | Open RoundFile      |
| 2          | Visual TurboBuilder |
| 3          | ReConsider          |

#### BugsProducts
| bug_id | product_id |
|--------|------------|
| 1234   | 1          |
| 2248   | 1          |
| 3456   | 2          |
| 4077   | 2          |
| 5150   | 2          |
| 5678   | 3          |
| 8063   | 3          |

#### Bugs
| bud_id | date_reported |                                 |
|--------|---------------|---------------------------------|
| 1234   | 2009-12-19    |                                 |
| 2248   | 2010-06-01    | Open RoundFileの最新のバグ      |
| 3456   | 2010-02-16    | Visual TurboBuilderの最新のバグ |
| 4077   | 2010-02-10    |                                 |
| 5150   | 2010-02-16    |                                 |
| 5678   | 2010-01-01    | ReConsiderの最新のバグ          |
| 8063   | 2009-11-09    |                                 |

### 期待値
| product_name        | latest     | bug_id |
|---------------------|------------|--------|
| Open RoundFile      | 2010-06-01 | 2248   |
| Visual TurboBuilder | 2010-02-16 | 3456   |
| ReConsider          | 2010-01-01 | 5678   |


## アンチパターン
### 非グループ化列を参照する
#### どんなパターン？
* `GROUP BY`してないデータを`SELECT`対象に含める

#### クエリ例
```sql
SELECT
  product_id,
  MAX(date_reported) AS latest,
  bug_id
FROM
  Bugs
  INNER JOIN BugsProducts USING (bug_id)
GROUP BY
  product_id
```

#### 問題点
* エラーになる
* 思ったとおりの結果にならない

#### 思ったとおりの結果にならない例
| product_name        | latest     | bug_id   |
|---------------------|------------|----------|
| Open RoundFile      | 2010-06-01 | **1234** |
| Visual TurboBuilder | 2010-02-16 | 3456     |
| ReConsider          | 2010-01-01 | 5678     |

#### Why?
* **単一の原則**に違反している


## 解決方法
### 関数従属性のある列のみクエリを実行する
#### どんなパターン？
* `MAX()`みたいな、一つの値に特定することが可能な列だけ使う

#### クエリ例
```sql
SELECT
  product_id,
  MAX(date_reported) AS latest -- 単一値を保証できる
FROM
  Bugs
  INNER JOIN BugsProducts USING (bug_id)
GROUP BY
  product_id
```

#### 感想
* これで問題ないならシンプルだしええんちゃう

---

### 相関サブクエリを使用する
#### どんなパターン？
* 外部クエリへの参照を含むサブクエリを使う

#### クエリ例
```sql
SELECT
  bp1.product_id,
  b1.date_reported AS latest,
  b1.bug_id
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 USING (bug_id)
WHERE
  -- 行ごとにでdate_reportedがより新しいものが存在していないかをチェック
  NOT EXISTS (
    SELECT
      *
    FROM
      Bugs b2
      INNER JOIN BugsProducts bp2 USING (bug_id)
    WHERE
      bp1.product_id = bp2.product_id
      AND b1.date_reported < b2.date_reported
  )
```

#### 結果
| product_name        | latest     | bug_id |
|---------------------|------------|--------|
| Open RoundFile      | 2010-06-01 | 2248   |
| Visual TurboBuilder | 2010-02-16 | 3456   |
| ReConsider          | 2010-01-01 | 5678   |

#### 感想
* ちょっとSQL力が問われるようになるけど、相関サブクエリは覚えとくとなにか集計したいってなったときに便利
* パフォーマンスはゴミクズなので行数が多いテーブルに対して実行するときは注意

---

### JOINを使用する
#### どんなパターン？
* 外部結合使って頑張れ

#### クエリ例
```sql
SELECT
  bp1.product_id,
  b1.date_reported AS latest,
  b1.bug_id
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
  LEFT OUTER JOIN (
    Bugs AS b2
    INNER JOIN BugsProducts AS bp2 ON b2.bug_id = bp2.bug_id
  )
  ON (
        bp1.product_id = bp2.product_id
      AND (
          b1.date_reported < b2.date_reported
        OR
          b1.date_reported = b2.date_reported
        AND
          b1.bug_id < b2.bug_id
      )
    )
WHERE
  b2.bug_id IS NULL;
```

#### 結果
| product_name        | latest     | bug_id |
|---------------------|------------|--------|
| Open RoundFile      | 2010-06-01 | 2248   |
| Visual TurboBuilder | 2010-02-16 | 3456   |
| ReConsider          | 2010-01-01 | 5678   |


#### 説明！
##### 最初のINNER JOINまで見てみる
```sql
SELECT
  *
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
```

| bp1.product_id | b1.date_reported | bp1.bug_id |
|----------------|------------------|------------|
| 1              | 2009-12-19       | 1234       |
| 1              | 2010-06-01       | 2248       |

##### LEFT OUTER JOINの条件を単純化して見てみる
```sql
SELECT
  bp1.product_id,
  b1.date_reported AS latest,
  b1.bug_id
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
  LEFT OUTER JOIN (
    Bugs AS b2
    INNER JOIN BugsProducts AS bp2 ON b2.bug_id = bp2.bug_id
  )
  ON bp1.product_id = bp2.product_id
```

| bp1.product_id | b1.date_reported | bp1.bug_id | bp2.product_id | b2.date_reported | bp2.bug_id |
|----------------|------------------|------------|----------------|------------------|------------|
| 1              | 2009-12-19       | 1234       | 1              | 2009-12-19       | 1234       |
| 1              | 2009-12-19       | 1234       | 1              | 2010-06-01       | 2248       |
| 1              | 2010-06-01       | 2248       | 1              | 2009-12-19       | 1234       |
| 1              | 2010-06-01       | 2248       | 1              | 2010-06-01       | 2248       |

##### LEFT OUTER JOINの条件の日付フィルタリングを追加してみる
```sql
SELECT
  *
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
  LEFT OUTER JOIN (
    Bugs AS b2
    INNER JOIN BugsProducts AS bp2 ON b2.bug_id = bp2.bug_id
  )
  ON (
        bp1.product_id = bp2.product_id
      AND (
          b1.date_reported < b2.date_reported
        OR
          b1.date_reported = b2.date_reported
      )
  )
```

| bp1.product_id | b1.date_reported | bp1.bug_id | bp2.product_id | b2.date_reported | bp2.bug_id |
|----------------|------------------|------------|----------------|------------------|------------|
| 1              | 2009-12-19       | 1234       | 1              | 2010-06-01       | 2248       |
| 1              | 2010-06-01       | 2248       | 1              | 2010-06-01       | 2248       |

##### LEFT OUTER JOINの条件のbug_idフィルタリングを追加してみる
```sql
SELECT
  *
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
  LEFT OUTER JOIN (
    Bugs AS b2
    INNER JOIN BugsProducts AS bp2 ON b2.bug_id = bp2.bug_id
  )
  ON (
        bp1.product_id = bp2.product_id
      AND (
          b1.date_reported < b2.date_reported
        OR
          b1.date_reported = b2.date_reported
        AND
          b1.bug_id < b2.bug_id
      )
  )
```

| bp1.product_id | b1.date_reported | bp1.bug_id | bp2.product_id | b2.date_reported | bp2.bug_id |
|----------------|------------------|------------|----------------|------------------|------------|
| 1              | 2009-12-19       | 1234       | 1              | 2010-06-01       | 2248       |
| 1              | 2010-06-01       | 2248       | NULL           | NULL             | NULL       |

##### WHERE条件を追加してみる
```sql
SELECT
  *
FROM
  Bugs b1
  INNER JOIN BugsProducts bp1 ON b1.bug_id = bp1.bug_id
  LEFT OUTER JOIN (
    Bugs AS b2
    INNER JOIN BugsProducts AS bp2 ON b2.bug_id = bp2.bug_id
  )
  ON (
        bp1.product_id = bp2.product_id
      AND (
          b1.date_reported < b2.date_reported
        OR
          b1.date_reported = b2.date_reported
        AND
          b1.bug_id < b2.bug_id
      )
  )
WHERE
  b2.bug_id IS NULL;
```

| bp1.product_id | b1.date_reported | bp1.bug_id | bp2.product_id | b2.date_reported | bp2.bug_id |
|----------------|------------------|------------|----------------|------------------|------------|
| 1              | 2010-06-01       | 2248       | NULL           | NULL             | NULL       |

#### 感想
* なんだこのクソクエリぃ！（直球）
* IDがシーケンシャル（時系列順）じゃないとアカンくない。。。？

---

### 他の列に対しても集約関数を使用する
#### どんなパターン？
* 集約関数を酷使する

#### クエリ例
```sql
SELECT
  product_id,
  MAX(date_reported) AS latest,
  MAX(bug_id) AS latest_bug_id
FROM
  Bugs
  INNER JOIN BugsProducts USING (bug_id)
GROUP BY
  product_id;
```

#### 結果
| product_name        | latest     | latest_bug_id |
|---------------------|------------|---------------|
| Open RoundFile      | 2010-06-01 | 2248          |
| Visual TurboBuilder | 2010-02-16 | 3456          |
| ReConsider          | 2010-01-01 | 5678          |

#### 感想
* 誰もが最初に思いつく解決方法だと思う
* IDが時系列順なら楽でいいんじゃない？

---

### グループごとにすべての値を連結する
#### どんなパターン？
* 対象の全結果を含む列が追加される的な

####  クエリ例
```sql
SELECT
  product_id,
  MAX(date_reported) AS latest,
  GROUP_CONCAT (bug_id) AS bug_id_list
FROM
  Bugs
  INNER JOIN BugsProducts USING (bug_id)
GROUP BY
  product_id;
```

#### 結果
| product_id | latest     | bug_id_list    |
|------------|------------|----------------|
| 1          | 2010-06-01 | 1234,2248      |
| 2          | 2010-02-16 | 3456,4077,5150 |
| 3          | 2010-01-01 | 5678,8063      |


#### 感想
* 初めて知った。
* 覚えてたら使いみちはある。。のか。。。？
  - カンマ区切りにされてもなあという気持ちがすごい
    + なんかの団体イベントの出欠表みたいなのを出力するってときに、グループごとのメンバーのリストを１行で表現したいみたいな場合は使えるかも
* SQL標準じゃないって点もびみょい


## まとめ
* 最新の〜とか、一番高い〜のみ抽出みたいなのは、DWHとかでデータ分析するときによく出くわすパターン
  - 機械学習で特徴量作るときにまあよく出会った
* 紹介されてる中では相関サブクエリが何やってる一番わかるのでいいかなー
  - 概念覚えるまでは分かりづらいと思うけど、一度覚えるといろんなとこで使える
* あくまで集計したいって場合の解決方法なので、アプリケーションで最新の〜を取る必要がある場合はテーブル設計を見直したほうがいいと思われ
* WINDOW関数使ってもいいんじゃね？と思った。
  - 正しい結果出るかは試してないけど↓みたいな？？

    ```sql
    SELECT
      product_id,
      date_reported as latest,
      bug_id
    FROM (
      SELECT
        product_id,
        date_reported,
        bug_id,
        RANK() OVER (PARTITION BY product_id ORDER BY date_reported DESC) AS date_rank
      FROM
        Bugs
        INNER JOIN BugsProducts USING (bug_id)
    ) AS t
    WHERE
      date_rank = 1;
    ```
