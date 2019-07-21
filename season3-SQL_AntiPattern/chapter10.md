# 第10章 サーティワンフレーバー(31のフレーバー)

| -        | -                |
|:---------|:-----------------|
| タイトル | SQLアンチパターン  |
| 起票日   | 2019/07/19       |
| 起票者   | @itor319          |
| 機能     | -                |

## 概要
元ネタは有名なアイスクリーム。  
なんかたくさんのフレーバーがあって月毎とかに提供するフレーバーが変わるらしい。  
伊藤は食べたことないのでよく知らない。

## 現象と期待動作
### 原因
連絡先情報テーブルみたいのがあって、その中の敬称列とかで起こるっぽい。  

```
CREATE TABLE personalContacts (
  -- なんか他の列 --
  salutation VARCHAR(4)
    CHECK (salutation IN ('Mr.', 'Mrs.', 'Ms.'))
);
```

上記みたいな列の中に「Mr.」「Mrs.」「Ms.」とか入れとけば大体網羅できるよね！  
しかしこのまま運用していってたら、それ以外も対応しなければならなくなった時に困る。（他の国の敬称の表現とか）

### 目的
やりたいことは、「列を特定の値に限定する」こと。

| bug_id | status        |
|:-------|:--------------|
| 1      | 'new'         |
| 2      | 'in progress' |
| 3      | 'fixed'       |

↑みたいなテーブルだとしてたら、status列には「new」「in progress」「fixed」という値しか許容しないイメージ。

### 問題点
### 中身がわからない  
```
SELECT DISTINCT staus FROM Bugs;
```
みたいなクエリを流して取得した結果を用いてドロップダウンを作ろうとした時、  
1つしかなかったりする場合を考慮しなくてはいけない。  
それを避けるためには、列のメタデータ定義を取得する必要が出てくる。
```
  -- MySQLでENUM使ってる場合INFORMATION_SCHEMとかで検索できるらしい --
SELECT column_type
  FROM information_schema.columns
  WHERE table_schema = 'bugtracker_schema'
    AND table_name = 'bugs'
    AND column_name = 'status';
```
ただ、これの返却は「ENUM('new','in progress','fixed')」のような文字列になってしまう。  
そうなると、個々の文字列を抽出するアプリケーションコードが必要になってくる。だるい。  
コレ系のクエリはだんだん複雑化するらしい。  
すると、アプリ側にもリストを用意してメンテしてってなってきてサボるとバグるみたいな未来が待ってる。怖い。

#### 定義の変更
```
ALTER TABLE Bugs MODIFY COLUMN status
  ENUM('new', 'in progress', 'fixed', 'duplicate');
```
みたいに定義を１つ追加するためには、`alter table`とか使って変更する必要がある。  
追加前の列定義を知ってないといけない。そのために、現在の列挙値を取得しなければならない。  
（既存のテーブル定義書とかで確認すればいいと思うけど…）

または

```
ALTER TABLE Bugs MODIFY COLUMN status
  ENUM('new', 'in progress', 'code complete', 'verified');
```
みたいな、既存の値が消えるやつ。  
既に格納されている者たちはどうするねん問題が発生する。

`alter table`で変更出来るって言うけど、サポートされてないDB製品の場合はどうすんねん問題もある。

#### 移植が困難
複数のDB製品をサポートしなければならない場合、製品によって仕様が違うので移植が難しい。  
（そんな場面に立ち会ったことないのでイメージ沸かない…）

## 対処方法
### 限定する値をデータで指定する
１つのテーブル内の列で定義すると面倒が起きるかもしれへんなぁ…  
せや！
```
CREATE TABLE BugStatus (
  status VARCHAR(20) PRIMARY KEY
);

INSERT INTO BugStatus (status) VALUES ('new'), ('in progress'), (fixed);

CREATE TABLE Bugs(
  -- 他の列 --
  status VARCHAR(20),
  FOREIGN KEY (status) REFERENCES BugStatus (status)
    ON UPDARE CASCADE
);
```
い　つ　も　の
参照テーブル作って解決。

#### 値セットの取得
```
SELECT status FROM BugStatus ORDER BY status;
```
`select`で容易。  
`order by`でソートもできちゃう。

#### 値の更新
```
-- 値の追加 --
INSET INTO BugStatus (status) VALUES ('duplicate');

ｰｰ 値の変更 ｰｰ
UPDATE BugStatus SET status = 'invalid' where status = 'bogus';
```
新しく作った参照テーブル側にそのまま`insert`してもおっけー。  
外部キーに`cascade`付与しておけば`update`も容易。

#### 廃止した値のサポート
既に存在する値は、外部キー制約によって削除ができなくなる。
なので別の方法で管理する。
```
ALTER TABLE BugStatus ADD COLUMN active
  ENUM ('inactive', 'active') NOT NULL DEFAULT 'active';
```
このように新しく列を作成し有効値を区別する。  
こうすることで、値を削除するのではなく、有効値で判別できるようにし、
```
UPDATE BugStatus SET active = 'inactive' WHERE status = 'duplicate';
```
値の有効値を`update`で切り替えることが出来るようになる。  
`select`時に条件を付与すれば、有効なものだけを取得出来る。

#### 移植が容易
参照テーブルを用いた設計にすれば、外部キー制約という標準的なSQL機能で解決できるので移植が簡単に行える。

## アンチパターンを使ってもよいパターン
### 値セットが変わらないもの
相互排他的なもの（右と左、有効と無効、みたいな）に関しては使っていいっぽい。  
CHECK制約で`start < end`のチェックもできる。
