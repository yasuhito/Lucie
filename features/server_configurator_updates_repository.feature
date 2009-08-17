# language: ja
機能: サーバーコンフィグレータが Lucie サーバ上の設定リポジトリを更新する

  サーバーコンフィグレータは
  各 Lucie クライアントの設定を更新するために
  まずは Lucie サーバの設定リポジトリを最新版に更新する

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

  テンプレ:
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし サーバーコンフィグレータがその設定リポジトリを更新した
    ならば その設定リポジトリが "<COMMAND>" コマンドで更新される

    例:
      | SCM        | URL                               | COMMAND    |
      | mercurial  | ssh://myrepos.org//lucie/clone_me | hg update  |
      | git        | git://myrepos.org//lucie/clone_me | git update |
      | subversion | http://myrepos.org/lucie/clone_me | svn update |
