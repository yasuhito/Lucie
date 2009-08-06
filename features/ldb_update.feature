# language: ja
機能: LDB がクライアント上の設定リポジトリを更新する

  LDB は
  クライアント上の設定リポジトリを更新するために
  サーバ上の設定リポジトリを更新し、ついでクライアント上の設定リポジトリを更新する

  背景:
    前提 ドライランモードがオン
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: 設定の更新
    前提 Lucie クライアント "yasuhito_node" (IP アドレスは "192.168.0.1")
    かつ LDB が Lucie サーバに設定リポジトリ "http://myrepos.org/myconfig" を複製
    かつ LDB がその複製を Lucie クライアント "yasuhito_node" へ配置した
    もし LDB がクライアント "yasuhito_node" の更新を実行した
    ならば Lucie サーバの設定リポジトリが更新される
    かつ Lucie サーバの設定リポジトリ複製が更新される
    かつ Lucie クライアント "yasuhito_node" の設定リポジトリが更新される
