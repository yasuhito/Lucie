# language: ja
機能: コンフィグレータが Lucie クライアント上の設定リポジトリを更新する

  コンフィグレータは
  Lucie クライアントの設定を更新するために
  Lucie クライアント上の設定リポジトリを更新する

  背景:
    前提 ドライランモードがオン

  シナリオ: 設定の更新
    前提 Lucie クライアント "yasuhito_node" (IP アドレスは "192.168.0.1")
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "http://myrepos.org/myconfig" を複製
    かつ コンフィグレータがその複製を Lucie クライアント "yasuhito_node" へ配置した
    もし コンフィグレータが Lucie クライアント "yasuhito_node" の更新を実行した
    ならば Lucie クライアント "yasuhito_node" の設定リポジトリが更新される
