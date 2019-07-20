# 第１５章 ランダムセレクション
## 概要
適当なデータがほしいんやけど！


## アンチパターン
### データをランダムにソートする
#### どんなパターン？
* `GROUP BY`してないデータを`SELECT`対象に含める

#### クエリ例
```sql
SELECT
  *
FROM
  Bugs
ORDER BY
  RAND()
LIMIT 1;

```

#### 問題点
* パフォーマンスがやばい

#### Why?
* 行ごとにランダムな値を使ってソートをかけるため事前にインデックス貼れない
  - データ量が増えれば増えるほど顕著になってく
  - さらに、結果セットの最初の１行しか使わんのでソートの大部分が無駄になるのでいくない


## 解決方法
### １と最大値の間のランダムなキー値を選択する
#### どんなパターン？
* 抽出対象のIDを乱数使って計算しようぜ

#### クエリ例
```sql
SELECT
  b1.*
FROM
  Bugs AS b1
  INNER JOIN (
    SELECT
      CEIL(
        RAND() * (SELECT MAX(bug_id) FROM Bugs) -- 乱数(0 <= n < 1.0) * bug_idの最大値
      ) AS rand_id
  ) AS b2
  ON b1.bug_id = b2.rand_id;
```

#### 感想
* IDがシーケンシャルかつ欠番ないこと前提。微妙。
* MySQLのリファレンス見たけど、乱数範囲が(`0 <= n < 1.0`)みたいだから乱数で0引いたら駄目じゃね？

---

### 欠番の穴の後にあるキー値を選択する
#### どんなパターン？
* [１と最大値の間のランダムなキー値を選択する](#１と最大値の間のランダムなキー値を選択する)とほぼ一緒。欠番がある時用

#### クエリ例
```sql
SELECT
  b1.*
FROM
  Bugs AS b1
  INNER JOIN (
    SELECT
      CEIL(RAND() * (SELECTMAX(bug_id) FROM Bugs)) AS bug_id
  ) AS b2 ON b1.bug_id >= b2.bug_id -- 乱数以上のIDを持つデータを抽出
-- bug_idで並び替えて最初に取れたやつをGET
ORDER BY
  b1.bug_id
LIMIT 1;
```

#### 感想
* これもシーケンシャルなID前提なのでびみょいなー
* この抽出方法なら[１と最大値の間のランダムなキー値を選択する](#１と最大値の間のランダムなキー値を選択する)に書いた乱数で0引いたときも問題はでないと思う。

---

### すべてのキー値のリストを受け取り、ランダムに一つを選択する
#### どんなパターン？
* タイトル通り
* DBでできないならアプリケーション側でやりゃええねん！ってやつ

#### プログラム例
```php
<?php
$bug_id_list =
    $pdo->query("SELECT bug_id FROM Bugs")->fetchAll(PDO::FETCH_ASSOC);

$rand = rand( 0, count($bug_id_list) - 1 );
$rand_bug_id = intval($bug_id_list[$rand]['bug_id']);

$stmt = $pdo->prepare("SELECT * FROM Bugs WHERE bug_id = ?");
$stmt->bindValue(1, $rand_bug_id, PDO::PARAM_INT);
$stmt->execute();
$rand_bug = $stmt->fetch();
```

#### 感想
* せやな。って感じ
* IDの法則性とか気にしなくていいから現実的ではある

---

### オフセットを用いてランダムに行を選択する
#### どんなパターン？
* 抽出開始する行（オフセット）を乱数使って指定するやつ

#### プログラム例
```php
<?php
$rand_sql = "SELECT FLOOR(
    RAND() * (SELECT COUNT(*) FROM Bugs)
  ) AS id_offset";
$result = $pdo->query($rand_sql)->fetch(PDO::FETCH_ASSOC);
$offset = intval($result['id_offset']);

$sql = "SELECT * FROM Bugs LIMIT 1 OFFSET :offset";
$stmt = $pdo->prepare($sql);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();
$rand_bug = $stmt->fetch();”
```

#### 感想
* せやな。って感じ（２回目）
* 処理量とか考えると妥当な気がしないでもないけどなんかモヤモヤすんなー


## まとめ
* 典型的なベストプラクティスがない系のパターンだと思う
  - どうやってもしっくりこない
* 最近流行りつつある分散データベースでは、そもそもPKをシーケンシャルにするのはアンチパターンなので、PKの法則性に頼った解決方法は使えない
  - 同様にOFFSET、LIMIT指定のパターンも、内部的には全件抽出して指定された行だけ返すため、分散されて保存されているデータすべてをフェッチする必要がある分オーバーヘッドがでかい
* ランダム選択したいケースでは、`最新の○件の中からランダム`のような条件を付けても問題無いケースがほとんどだと思うので、件数絞ってアプリケーションで抽出対象のPKを乱数で選択する方式がいいんじゃないかと思ってはいる
* **いろいろ考えては見たけど、やっぱりいい方法が思いつかんので誰か教えて！**
