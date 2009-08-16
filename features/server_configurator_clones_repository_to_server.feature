# language: ja
機能: サーバーコンフィグレータが Lucie サーバに設定リポジトリを複製する

  サーバーコンフィグレータは
  設定リポジトリを各 Lucie クライアントに配置するために
  設定リポジトリの複製を Lucie サーバに配置する

  テンプレ: リポジトリを Lucie サーバに複製
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    もし サーバーコンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    ならば "<COMMAND>" コマンドで設定リポジトリが Lucie サーバに複製される
    かつ エラーが発生しない

    例:
      | SCM        | URL                               | COMMAND   |
      | Mercurial  | ssh://myrepos.org//lucie/clone_me | hg clone  |
      | Git        | git://myrepos.org//lucie/clone_me | git clone |
      | Subversion | http://myrepos.org/lucie/clone_me | svn co    |

  シナリオ: SCM が指定されていない
    前提 バックエンドの SCM が指定されていないサーバーコンフィグレータ
    もし サーバーコンフィグレータが Lucie サーバに設定リポジトリ "ssh://myrepos.org//lucie/clone_me" を複製
    ならば エラー "scm is not specified"
