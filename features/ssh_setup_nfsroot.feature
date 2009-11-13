# language: ja
機能: nfsroot への SSH ログインのセットアップ

  Lucie のインストールコマンドは
  SSH 経由で Lucie クライアントのインストールを実行できるようにするために
  nfsroot に SSH の鍵を仕込んで、SSH ログインできるようにしておく

  シナリオ: SSH の鍵を仕込む
    前提 nfsroot のパスは "/tmp/nfsroot"
    もし nfsroot に SSH の鍵を仕込もうとした
    ならば nfsroot への SSH ログインができるようになる

