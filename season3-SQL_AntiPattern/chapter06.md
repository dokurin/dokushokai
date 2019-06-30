# 第６章 ポリモーフィック関連
## 概要
RDBで `has-a` なリレーションをどう表現しようか的な

![こんなの](https://user-images.githubusercontent.com/6662577/60384673-5826a400-9abb-11e9-8d6d-9df84d8c91ce.png)


## アンチパターン
### 二重目的の外部キーを使用(ポリモーフィック関連, プロミスキャス・アソシエーション)
#### どんなパターン？
* 複数のテーブルとJOINされるカラムを定義する

#### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  issue_type   VARCHAR(20), -- 'Bugs' または 'FeatureRequests' が格納される
  issue_id     BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME,
  comment      TEXT,
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
```

#### 問題点
* `issue_id` に外部キー制約を指定できない


## 解決方法
### 参照を逆にする
#### どんなパターン？
* ポリモーフィック関連の参照を逆にしたやつ

#### テーブル定義
![Comments](https://user-images.githubusercontent.com/6662577/60393835-9329e580-9b56-11e9-8a8c-5d7e9b8e698f.png)

```sql
CREATE TABLE `Comments` (
  `comment_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_date` datetime DEFAULT NULL,
  `comment` text,
  PRIMARY KEY (`comment_id`),
  UNIQUE KEY `comment_id` (`comment_id`)
);

CREATE TABLE `Bugs` (
  `bug_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint(20) unsigned NOT NULL, -- 参照先のComments
  PRIMARY KEY (`bug_id`),
  UNIQUE KEY `bug_id` (`bug_id`),
  KEY `comment_id` (`comment_id`),
  CONSTRAINT `Bugs_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `Comments` (`comment_id`)
);

CREATE TABLE `FeatureRequests` (
  `feature_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint(20) unsigned NOT NULL, -- 参照先のComments
  PRIMARY KEY (`feature_id`),
  UNIQUE KEY `feature_id` (`feature_id`),
  KEY `comment_id` (`comment_id`),
  CONSTRAINT `FeatureRequests_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `Comments` (`comment_id`)
);
```

#### 感想
* とりあえずこれ試せば？という気持ち
* 複数のコメントを持つ場合とかは次に説明する交差テーブル使おう

---

### 交差テーブルの作成
#### どんなパターン？
* [第１章に登場した交差テーブル](chapter01.md#%E5%AF%BE%E5%87%A6%E6%96%B9%E6%B3%95)と上で説明したやつの組み合わせ

#### テーブル定義
```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME,
  comment      TEXT,
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);

CREATE TABLE BugsComments (
  issue_id    BIGINT UNSIGNED NOT NULL,
  comment_id  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (issue_id, comment_id),
  FOREIGN KEY (issue_id) REFERENCES Bugs(issue_id),
  FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);

CREATE TABLE FeaturesComments (
  issue_id    BIGINT UNSIGNED NOT NULL,
  comment_id  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (issue_id, comment_id),
  FOREIGN KEY (issue_id) REFERENCES FeatureRequests(issue_id),
  FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);
```

#### 問題点とか
* 交差テーブルはN対Nの関連付け作成できてしまうので、コメントが複数のBugsとかFeatureRequestsに紐付いちゃう
  - UNIQUE制約付ければある程度対処できる
    + それでも完全には重複取り除けないのでアプリケーションで頑張る必要がある

#### 感想
* まあ無難かなーという気持ち
* 個人的にはこういうのをやろうとする場合は、無理せずにBugs用のCommentsとFeatureRequests用のCommentsで分ける気がする

---

### 共通の親テーブルの作成
#### どんなパターン？
* [第５章のクラステーブル継承](season3-SQL_AntiPattern/chapter05.md#%E3%82%AF%E3%83%A9%E3%82%B9%E3%83%86%E3%83%BC%E3%83%96%E3%83%AB%E7%B6%99%E6%89%BF)を利用
* 親テーブルの `Issues` とリレーションを定義する

#### テーブル定義
```sql
CREATE TABLE Issues (
  issue_id     SERIAL PRIMARY KEY
  . . .
);

CREATE TABLE Bugs (
  issue_id     BIGINT UNSIGNED PRIMARY KEY,
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id),
  . . .
);

CREATE TABLE FeatureRequests (
  issue_id     BIGINT UNSIGNED PRIMARY KEY,
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id),
  . . .
);

CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  issue_id     BIGINT UNSIGNED NOT NULL,
  author       BIGINT UNSIGNED NOT NULL,
  comment_date DATETIME,
  comment      TEXT,
  FOREIGN KEY (issue_id) REFERENCES Issues(issue_id),
  FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
```

#### 感想
* リレーション整合性など諸々考えると一番キレイ
* **Issueがコメントを持つ**というリレーションになので、最初の関連と変わっちゃってね？

##### こうだったはずが
![before](https://user-images.githubusercontent.com/6662577/60394106-d174d400-9b59-11e9-9162-e2d2340ab08f.png)

##### こうなってるよね
![after](https://user-images.githubusercontent.com/6662577/60394089-98d4fa80-9b59-11e9-9f60-749da1a3eba7.png)


## まとめ
* ５章、６章のデータ構造、リレーションの話はDB設計の難しいところの一つだと思う。
* 個人的には、この本で書いてるような感じのリレーションなら、それぞれ別のコメントテーブルを作るかなー
