# language: ja
機能: クライアントコンフィグレータが Lucie クライアントに設定リポジトリを配置する

  クライアントコンフィグレータは
  設定リポジトリの内容を Lucie クライアントに反映するために
  設定リポジトリを Lucie クライアントへ配置したい

  背景:
    前提 Lucie サーバの IP アドレスは "192.168.0.1"
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: Lucie クライアントにリポジトリを配置 (mercurial)
    前提 Lucie サーバ上に mercurial で管理された設定リポジトリ (ssh://myrepos.org//lucie) の複製が存在
    もし クライアントコンフィグレータがその設定リポジトリを Lucie クライアント (IP アドレスは "192.168.0.100") へ配置した
    ならば 設定リポジトリが scp コマンドで Lucie クライアントに配置される

  シナリオ: Lucie クライアントにリポジトリを配置 (git)
    前提 Lucie サーバ上に git で管理された設定リポジトリ (git://myrepos.org/lucie) の複製が存在
    もし クライアントコンフィグレータがその設定リポジトリを Lucie クライアント (IP アドレスは "192.168.0.100") へ配置した
    ならば 設定リポジトリが git clone コマンドで Lucie クライアントに配置される

  シナリオ: Lucie クライアントにリポジトリを配置 (subversion)
    前提 Lucie サーバ上に subversion で管理された設定リポジトリ (http://myrepos.org/lucie) の複製が存在
    もし クライアントコンフィグレータがその設定リポジトリを Lucie クライアント (IP アドレスは "192.168.0.100") へ配置した
    ならば 設定リポジトリが scp コマンドで Lucie クライアントに配置される
