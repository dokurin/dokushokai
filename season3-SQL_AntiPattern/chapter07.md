# 第7章 マルチカラムアトリビュート(複数列属性)

| -        | -                |
|:---------|:-----------------|
| タイトル | SQLアンチパターン  |
| 起票日   | 2019/06/29       |
| 起票者   | @itor319          |
| 機能     | -                |

## 概要
マルチカラムアトリビュートってなんじゃらほい。  

```
CREATE TABLE Bugs (
  bug_id SERIAL PRIMARY KEY,
  description VARCHAR(1000),
  tag1 VARCHAR(20),
  tag2 VARCHAR(20),
  tag3 VARCHAR(20)  
);
```
みたいなテーブルがあって

| bug_id | description | tag1     | tag2        | tag3 |
|:-------|:------------|:---------|:------------|:-----|
| 1234   | 説明ほげ     | crash    | NULL        | NULL |
| 3456   | 説明ふが     | printing | performance | NULL |
| 5678   | 説明ぴよ     | NULL     | NULL        | NULL |

↑のテーブルのタグ列みたいなのを呼んでるらしい。  
連絡先の電話番号の入力欄が複数あるみたいな。

## 現象と期待動作
### 原因
前述した連絡先テーブル的なやつがあったり、バグのチケット管理とかのタスクに対してタグ付けしなくちゃいけないとか  
そんな感じのアプリ作成の時に起こり得るのかな…？

### 問題点
- 値の検索
 - 概要のテーブルでいうとタグ列３つ全てに検索を掛けなきゃいけない。

 ```
 SELECT * FROM Bugs
 WHERE tag1 = 'performance'
    OR tag2 = 'performance'
    OR tag3 = 'performance';
 ```
 - タグ２つ同時に検索掛けるとか。

 ```
SELECT * FROM Bugs
 WHERE (tag1 = 'performance' OR tag2 = 'performance' OR tag3 = 'performance')
   AND (tag1 = 'printing' OR tag2 = 'printing' OR tag3 = 'printing')

 もしくは↓ (こっちのほうがコンパクトでおすすめらしい)

 SELECT * FROM Bugs
 WHERE 'performance' IN (tag1, tag2, tag3)
   AND 'printing' IN (tag1, tag2, tag3);
 ```
- 値の追加と削除
 - UPDATEする前にどの列が空いているかチェックしなければならない。
 - チェックして更新までの間に競合するかもしれない。
 - SQL１発で終わらせるにしても長くてめんどい。

 ```
 UPDATE Bugs
    SET tag1 = NULLIF(tag1, 'performance'),
        tag2 = NULLIF(tag2, 'performance'),
        tag3 = NULLIF(tag3, 'performance')
    WHERE bug_id = 3456;

 もしくは↓

 UPDATE Bugs
    SET tag1 = CASE
        WHEN 'performance' IN (tag2, tag3) THEN tag1
        ELSE COALESCE(tag1, 'performance') END,
        tag2 = CASE
        WHEN 'performance' IN (tag1, tag3) THEN tag2
        ELSE COALESCE(tag2, 'performance') END,
        tag3 = CASE
        WHEN 'performance' IN (tag1, tag2) THEN tag3
        ELSE COALESCE(tag3, 'performance') END,
    WHERE bug_id = 3456;
 ```
- 一意性の保証
 - 以下のようなものを防げない。

 ```
 INSERT INTO Bugs (description, tag1, tag2 ,tag3)
   VALUES ('ほげほげ', 'printing', 'performance', 'performance');
 ```
- 増加する値の処理
 - 設計初期段階では必要な枠の数が分かり辛いので後々拡張する必要が出てくるかもしれない。  
 そうなると、テーブル全体をロックする必要や、その部分に関わるコードの修正が発生したりするかもしれないからめんどい。  
 また、DB製品によってはADD COLUMNとかできなかったらめんどいよね。


## 対処方法
### 従属テーブル作ろうず
属性値を複数の列ではなく、複数の行に格納する。

```
CREATE TABLE Tags (
  bug_id BIGINT UNSIGNED NOT NULL,
  tag VARCHAR(20),
  PRIMARY KEY (bug_id, tag),
  FOREIGN KEY (bug_id) REFERENCES Bugs(bug_id)
);

INSERT INTO Tags (bug_id, tag)
  VALUES (1234, 'crash'), (3456, 'printing'), (3456, 'performance');
```

こうすると

| bug_id | tag           |
|:-------|:--------------|
| 1234   | 'crash'       |
| 3456   | 'printing'    |
| 3456   | 'performance' |

こんな感じのテーブルができるのでこっちで管理しようずって方法。  
「同じ意味を持つ値は、１つの列に格納するようにしましょう。」とのこと。

## アンチパターンを使ってもよいパターン
### 属性値の選択肢を限定できる場合
| bug_id | description | tag1     | tag2        | tag3    |
|:-------|:------------|:---------|:------------|:--------|
| 1234   | 説明ほげ     | Takeru   | NULL        | NULL    |
| 3456   | 説明ふが     | David    | Satoshi     | NULL    |
| 5678   | 説明ぴよ     | NULL     | NULL        | Takeshi |

- tag1にはバグを報告したユーザー
- tag2には修正する、したユーザー
- tag3には確認する、したユーザー

このように、意味合いや役割が異なる場合などは使ってもよいらしい。  
各属性値が同じ意味ではないので、検索で引っ掛ける方法も変わってくるよねってイメージ？
