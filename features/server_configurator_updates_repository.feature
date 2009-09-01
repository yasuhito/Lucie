# language: ja
機能: サーバーコンフィグレータが Lucie サーバ上の設定リポジトリを更新する

  サーバーコンフィグレータは
  各 Lucie クライアントの設定を更新するために
  まずは Lucie サーバの設定リポジトリを最新版に更新する

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: Mercurial の場合
    前提 Mercurial がインストールされている
    かつ バックエンドとして Mercurial を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "ssh://myrepos.org//lucie/clone_me" を複製
    もし サーバーコンフィグレータがその設定リポジトリを更新した
    ならば その設定リポジトリが "hg pull, hg update" コマンドで更新される
    かつ その設定リポジトリのローカル複製が "hg pull, hg update" コマンドで更新される

  テンプレ: Mercurial 以外の場合
    前提 <SCM> がインストールされている
    かつ バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "<URL>" を複製
    もし サーバーコンフィグレータがその設定リポジトリを更新した
    ならば その設定リポジトリが "<COMMAND>" コマンドで更新される

    例:
      | SCM        | URL                               | COMMAND              |
      | Git        | git://myrepos.org//lucie/clone_me | git pull, git update |
      | Subversion | http://myrepos.org/lucie/clone_me | svn update           |
