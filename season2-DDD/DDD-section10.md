# 10章の目的
クライアントにも開発者にも資する設計
以下の2点を提示する。
　1. イテレーションとリファクタリングを深化させることでどのような設計を目指すのか
　1. しなやかな設計を作り出すためにどのような実験を行うべきか。

# 意図の明白なインターフェース
クラスやメソッドに対し
　1. 概念を反映した名前をプログラム要素に与える
  1. 概念を明示的にモデル化する

クラスと操作
　操作とコマンドの2種類に分けられる。

クエリ：システムから情報を取得するもの
コマンド：システムに何らかの変更を与える操作

システムに何らかの変更を与えるコマンドのことを副作用のある操作と呼ぶ。
関数を活用する。

コマンドとクエリを別々の操作に分離する方法
副作用のある場合はドメインデータを返さない
クエリと演算は全て副作用を起こさないメソッドにする。
既存のオブジェクトを変更せずに処理の結果を表す新しいオブジェクトを返却する方法

疑問）１つめの方法�の、ドメインデータはエンティティのこと？
エンティティにvoidの操作を追加するってことか？それとも、レポジトリとファクトリをうまく使えってこと？

　その効果と目的を記述するユビキタス言語での名前をつける。
　手段に言及せず、目的に絞ることで中を見る必要をなくす。
　※手段はカプセル化する。


副作用を減らすために
1. 操作ではなく、関数を用いる
1. コマンドとクエリを別々の操作に厳密に分離しておく
1. クエリと演算は、すべて目に見える副作用を起こさないメソッドで実行する。

まとめ
1. プログラムロジックはできる限り関数に置く
1. コマンドは厳密に分離して、ドメインについての情報は戻さない
1. 値オブジェクトに責任を持たせられるなら、値オブジェクトを利用する。

# 表明
エンティティ上の副作用を表明する。副作用を０にすることはできない。
1. 操作の事後条件とクラス及び集約の不変条件を宣言する。
1. プログラミン言語で表明できないときは、自動化されたユニットテストで書く。
　　この場合表明をドキュメンテーションの図の中に記載する。
1. 概念の凝集を忘れるな

## 表明の性質
プログラミング言語でサポートされていないこともできる。
状態を書く物なので、テストを書くのが容易になる。
※テストを準備する際に事前条件を整え、実行後に事後条件が成り立っているかで判定する。

P.263はリファクタリング事例。

# 概念の輪郭
クライアントに意味を最大限持たせると機能は重複する。
一方でクラスやメソッドを分割すると複雑化して概念を複雑化させる

リファクタリングを行う方向性として、高凝集・低結合に向かう。
設計の用途が広がるようにする。（汎用性）

# 独立したクラス
・オブジェクトのイメージの中から他の概念をすべて取り除く
※同じモジュール内、特に緊密に結合しているのであれば依存関係は許容される。
・低結合を目指せ

## 閉じた操作
戻り値の型が引数の型と同じにできる場合は、そのように操作を定義すること
実装クラスが処理で使われる状態であれば、そのクラスは事実上操作の引数となるため、引数と戻り値は実装クラスと同じ型
インスタンス集合の下で閉じた状態にする。





