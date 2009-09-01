# language: ja
機能: コンフィグレータが Lucie サーバ上の設定リポジトリを更新する

  コンフィグレータは
  クライアント上の設定リポジトリを更新するために
  まずサーバ上の設定リポジトリを更新する

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: 設定の更新
    前提 Lucie クライアント "yasuhito_node" (IP アドレスは "192.168.0.1")
    かつ Mercurial がインストールされている
    かつ バックエンド が Mercurial のコンフィグレータ
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "http://myrepos.org/myconfig" を複製
    かつ コンフィグレータがその複製を Lucie クライアント "yasuhito_node" へ配置した
    もし コンフィグレータがノード "yasuhito_node" の更新のために Lucie サーバの更新を実行した
    ならば Lucie サーバの設定リポジトリが更新される
    かつ Lucie サーバの設定リポジトリ複製が更新される
