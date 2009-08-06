# language: ja
機能: サーバーコンフィグレータが Lucie サーバにローカルな設定リポジトリの複製を作る

  サーバーコンフィグレータは
  省メモリで設定リポジトリを Lucie クライアント上に複製するために
  Lucie サーバ上に設定リポジトリのローカル複製を作る

  背景:
    前提 ドライランモードがオン
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  テンプレ:
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし サーバーコンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成
    ならば "<COMMAND>" コマンドでローカルな設定リポジトリの複製が作成される

    例:
      | SCM        | URL                               | COMMAND   |
      | mercurial  | ssh://myrepos.org//lucie/clone_me | hg clone  |
      | git        | git://myrepos.org//lucie/clone_me | git clone |
      | subversion | http://myrepos.org/lucie/clone_me | svn co    |
