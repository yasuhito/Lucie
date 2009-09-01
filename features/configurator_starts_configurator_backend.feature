# language: ja
機能: コンフィグレータがバックエンドのコンフィグレータを実行する

  コンフィグレータは
  Lucie クライアントへ設定を反映させるために
  バックエンドのコンフィグレータを Lucie クライアント上で実行する

  シナリオ: バックエンドのコンフィグレータを実行
    前提 Lucie クライアント "yasuhito_node" (IP アドレスは "192.168.0.1")
    かつ Mercurial がインストールされている
    かつ バックエンド が Mercurial のコンフィグレータ
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "http://myrepos.org/myconfig" を複製
    かつ コンフィグレータがその複製を Lucie クライアント "yasuhito_node" へ配置した
    もし コンフィグレータがバックエンドのコンフィグレータを Lucie クライアント "yasuhito_node" 上で実行
    ならば バックエンドのコンフィグレータが Lucie クライアント "yasuhito_node" 上で実行される
