# language: ja
機能: コンフィグレータが Lucie サーバ上の設定リポジトリを更新する

  コンフィグレータは
  各 Lucie クライアントの設定を更新するために
  まずは Lucie サーバの設定リポジトリを最新版に更新する

  背景:
    前提 ドライランモードがオン
    かつ 冗長モードがオン
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  テンプレ:
    前提 バックエンドとして <SCM> を指定したコンフィグレータ
    かつ コンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし コンフィグレータがその設定リポジトリを更新した
    ならば その設定リポジトリが "<COMMAND>" コマンドで更新される

    例:
      | SCM        | URL                               | COMMAND    |
      | mercurial  | ssh://myrepos.org//lucie/clone_me | hg update  |
      | git        | git://myrepos.org//lucie/clone_me | git update |
      | subversion | http://myrepos.org/lucie/clone_me | svn update |
