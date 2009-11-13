# language: ja
機能: SSH の基本的な機能

  Lucie のインストールコマンドは
  Lucie クライアント上でインストールスクリプトを実行するために  
  SCP でインストールスクリプトを Lucie クライアント送り込んで SSH で実行できる必要がある

  シナリオ: SSH
    もし SSH でノード "yutaro_laptop" にコマンド "emacs" を実行
    ならば ノード "yutaro_laptop" 上でコマンド "emacs" が root 権限で実行される

  シナリオ: SSH (エージェントフォワーディングあり)
    もし SSH -A でノード "yutaro_laptop" にコマンド "emacs" を実行
    ならば エージェントフォワーディングを有効にした上で、ノード "yutaro_laptop" 上でコマンド "emacs" が root 権限で実行される

  シナリオ: SCP
    もし ファイル "/home/yutaro/MEMO" をノード "yutaro_laptop" の "/tmp" に SCP でコピー
    ならば ファイル "/home/yutaro/MEMO" がノード "yutaro_laptop" の "/tmp" に SCP でコピーされる

  シナリオ: SCP -r
    もし ディレクトリ "/home/yutaro/" をノード "yutaro_laptop" の "/home" に SCP -r でコピー
    ならば ディレクトリ "/home/yutaro/" がノード "yutaro_laptop" の "/home" に SCP -r でコピーされる

