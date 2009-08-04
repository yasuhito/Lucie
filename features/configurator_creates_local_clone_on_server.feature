# language: ja
機能: コンフィグレータが Lucie サーバにローカルな設定リポジトリの複製を作る

  コンフィグレータは
  省メモリで設定リポジトリを Lucie クライアント上に複製するために
  Lucie サーバ上に設定リポジトリのローカル複製を作る

  背景:
    前提 ドライランモードがオン
    かつ 冗長モードがオン
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  テンプレ:
    前提 バックエンドとして <SCM> を指定したコンフィグレータ
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし コンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成
    ならば "<COMMAND>" コマンドでローカルな設定リポジトリの複製が作成される

    例:
      | SCM        | URL                               | COMMAND   |
      | mercurial  | ssh://myrepos.org//lucie/clone_me | hg clone  |
      | git        | git://myrepos.org//lucie/clone_me | git clone |
      | subversion | http://myrepos.org/lucie/clone_me | svn co    |
