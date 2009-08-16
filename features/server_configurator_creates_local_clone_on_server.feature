# language: ja
機能: サーバーコンフィグレータが Lucie サーバにローカルな設定リポジトリの複製を作る

  サーバーコンフィグレータは
  省メモリで設定リポジトリを Lucie クライアント上に複製するために
  Lucie サーバ上に設定リポジトリのローカル複製を作る

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: Mercurial の場合は成功
    前提 バックエンドとして Mercurial を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "ssh://myrepos.org//lucie/clone_me" を複製
    もし サーバーコンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成
    ならば "hg clone" コマンドでローカルな設定リポジトリの複製が作成される
    かつ エラーが発生しない

  テンプレ: それ以外の場合は失敗
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし サーバーコンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成
    ならば エラー "<error>"

  例:
      | SCM        | URL                               | error                                      |
      | Git        | git://myrepos.org//lucie/clone_me | local clone is not supported on Git        |
      | Subversion | http://myrepos.org/lucie/clone_me | local clone is not supported on Subversion |
