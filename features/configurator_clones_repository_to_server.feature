# language: ja
機能: コンフィグレータがサーバにリポジトリを複製する

  リポジトリを各ノードに配置するために
  コンフィグレータとして
  リポジトリをサーバに複製する

  背景:
    前提 SCM として Mercurial を選択
    かつ コンフィグレータ

  シナリオ: リポジトリをサーバに複製
    前提 リポジトリの URL "http://myrepos.org/lucie/check_me_out"
    もし コンフィグレータがサーバにリポジトリを複製
    ならば hg clone コマンドで "http://myrepos.org/lucie/check_me_out" がサーバに複製された
