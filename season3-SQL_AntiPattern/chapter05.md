# 第５章 EAV(エンティティ・アトリビュート・バリュー)
## 概要
拡張性のあるDB設計について語ってる感じ。
`継承` のような概念をRDBでどう表現しましょうか的な。

## アンチパターン
### EAV(エンティティ・アトリビュート・バリュー)
#### どんなパターン？
* エンティティの属性のためのテーブルを定義
  - どんな値でも入れることができるカラムと、属性名のカラムを用意

```java
public abstract class Issue {
    public Date dateReported;
    public String reporter;
    public int priority;
    public String status;
}

public class Bug extends Issue {
    public String severity;
    public int versionOffected;
}

public class FeatureRequest extends Issue {
    public String sponsor;
}
```

```sql
CREATE TABLE IssueAttributes (
  issue_id BIGINT UNSIGNED NOT NULL,
  attr_name VARCHAR(100) NOT NULL, -- 属性名
  attr_value VARCHAR(100), -- 値
  PRIMARY KEY (issue_id, attr_name),
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id)
);
```

#### 問題点
* データの整合性を担保できない
  - `NUT NULL` 制約をつけたりは無理
* データ型での制約ができないためフリーダムな値が設定される可能性がある
  - 文字列として値を保存することになるため不整合な値が入る可能性あり
    + 数値型のはずなのに文字列入ってる
    + 日付のフォーマットがバラバラ
* 外部キー制約ができん
* 同じ形式を扱う属性でも属性名が違うことがある辛み
  - `date_reported` と `reoprt_date` とか
* 完全なデータを取得するためにJOINして色々がんばんなきゃなんない
* ORMとかでオブジェクトにバインディングしてくれないので、自力でプログラム書くことになる


## 解決方法
### シングルテーブル継承
#### どんなパターン？
* 子タイプで定義されている属性すべてをテーブルのカラムとする

#### テーブル定義
```sql
CREATE TABLE Issues (
  issue_id         SERIAL PRIMARY KEY,
  reported_by      BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED,
  priority         VARCHAR(20),
  version_resolved VARCHAR(20),
  status           VARCHAR(20),
  issue_type       VARCHAR(10), -- 'BUG' または 'FEATURE' が格納される
  severity         VARCHAR(20), -- Bug のみが使う属性
  version_affected VARCHAR(20), -- Bug のみが使う属性
  sponsor          VARCHAR(50), -- FeatureRequest のみが使う属性
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id)
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

#### 使用例
```sql
-- Bugの場合
INSERT INTO Issues(
  issue_id,
  reported_by,
  product_id,
  priority,
  version_resolved,
  status,
  issue_type,
  severity         -- Bugで利用する属性
  version_affected -- Bugで利用する属性
) VALUES (
  'xxxxxxxxx',
  1,
  2,
  'v0.1',
  'new',
  'BUG' -- issue_typeがBUG
  'high'
  'v0.1'
);

-- FeatureRequestの場合
INSERT INTO Issues(
  issue_id,
  reported_by,
  product_id,
  priority,
  version_resolved,
  status,
  issue_type,
  sponsor -- FeatureRequestで利用する属性
) VALUES (
  'xxxxxxxxx',
  1,
  2,
  'v0.1',
  'new',
  'FEATURE' -- issue_typeがFEATURE
  'high'
  'some sponsor'
);
```

#### 感想
* 愚直。
* 子タイプが増えるたびにカラムが増えるので結構つらみがあると思う
* NotNull制約とかできないよねという気持ち
* 「Active Recordパターンだと〜」って本に書かれてるけど、ほんまか？って気持ち
* 潜在バグ多めな気配を感じるので個人的にはあまり好まないぱてぃーん
  - Featureだけ抽出したいのに、issue_typeの絞り込み忘れでBugも取得できちゃった的な。
    + 絶対に表示しちゃいけない系のデータでこれやっちゃうと致命的


### 具象テーブル継承
* 子タイプ毎にテーブルを作る

#### テーブル定義
```sql
CREATE TABLE Bugs (
  issue_id         SERIAL PRIMARY KEY,
  reported_by      BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED,
  priority         VARCHAR(20),
  version_resolved VARCHAR(20),
  status           VARCHAR(20),
  severity         VARCHAR(20), -- Bug のみが使う属性
  version_affected VARCHAR(20), -- Bug のみが使う属性
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE FeatureRequests (
  issue_id         SERIAL PRIMARY KEY,
  reported_by      BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED,
  priority         VARCHAR(20),
  version_resolved VARCHAR(20),
  status           VARCHAR(20),
  sponsor          VARCHAR(50), -- FeatureRequest のみが使う属性
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

#### 感想
* これまた愚直。
* 親タイプの定義が変更になると、継承テーブルの定義をすべて変更する必要があるのでこれはこれで辛い。
* シングルテーブル継承とどっちが良いかと聞かれたらこっちのほうが好き
  - 抽出でのバグはまず発生しないので
* ORMの都合上この定義にすることが多いんじゃね？という感じがする


### クラステーブル継承
* 親タイプのテーブルと子タイプのテーブルを作る
* FK制約とかで継承を表現する

#### テーブル定義
```sql
-- 親タイプ
CREATE TABLE Issues (
  issue_id         SERIAL PRIMARY KEY,
  reported_by      BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED,
  priority         VARCHAR(20),
  version_resolved VARCHAR(20),
  status           VARCHAR(20),
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 子タイプ
CREATE TABLE Bugs (
  issue_id         BIGINT UNSIGNED PRIMARY KEY,
  severity         VARCHAR(20),
  version_affected VARCHAR(20),
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id)
);

-- 子タイプ
CREATE TABLE FeatureRequests (
  issue_id         BIGINT UNSIGNED PRIMARY KEY,
  sponsor          VARCHAR(50),
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id)
);
```

#### 感想
* 無駄がなくてきもてぃー
* ORMで愚直にバインディングしてくれないと思うので注意。


### 半構造化データ
* XMLとかJSONとかでシリアライズしちまおうぜ！

#### テーブル定義
```sql
CREATE TABLE Issues (
  issue_id         SERIAL PRIMARY KEY,
  reported_by      BIGINT UNSIGNED NOT NULL,
  product_id       BIGINT UNSIGNED,
  priority         VARCHAR(20),
  version_resolved VARCHAR(20),
  status           VARCHAR(20),
  issue_type       VARCHAR(10), -- 'BUG' または 'FEATURE' が格納される
  attributes       TEXT NOT NULL, -- その他の動的属性が格納される JSONとかにシリアライズしてぶち込め！
  FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

#### 感想
* JSON型とか出てきたし、割とありなパターンになってきた感ある。
* 「〇〇で検索したいんだけど」みたいなことを言われて詰む可能性があるので注意
  - 検索用テーブルを作るだとか全文検索エンジンを入れてどーのこーのとかなってくるやつ


## まとめ
* ちょっと設計こなれてきた系エンジニアがやりそうなパターンだなあと思った。
* アンケートみたいなデータ構造を表現しようとして「汎用性高いテーブル作ったった！」とドヤ顔でEAVパターンにしてしまう可能性あり

