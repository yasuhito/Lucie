# language: ja
機能: コンフィグレータが SCM を推測する

  コンフィグレータは
  Lucie クライアントの設定を更新するために
  コンフィグレータで使われている SCM の種類を推測する

  シナリオ: SCM の種類を推測
    前提 Lucie クライアント "yasuhito_node" (IP アドレスは "192.168.0.1")
    かつ バックエンド が Mercurial のコンフィグレータ
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "http://myrepos.org/myconfig" を複製
    かつ コンフィグレータがその複製を Lucie クライアント "yasuhito_node" へ配置した
    もし コンフィグレータが Lucie クライアント "yasuhito_node" の SCM を推測


