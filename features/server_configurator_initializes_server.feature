# language: ja
機能: サーバーコンフィグレータが Lucie サーバを初期化する

  サーバーコンフィグレータは
  設定リポジトリを Lucie サーバに複製するために
  Lucie サーバ上に必要な環境の初期化をしたい

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: 設定リポジトリ用ディレクトリの作成
    前提 設定リポジトリ用ディレクトリが Lucie サーバ上に存在しない
    もし サーバーコンフィグレータが Lucie サーバを初期化した
    ならば 設定リポジトリ用ディレクトリが Lucie サーバ上に生成される

  シナリオ: 設定リポジトリ用ディレクトリの生成をスキップ
    前提 設定リポジトリ用ディレクトリが Lucie サーバ上にすでに存在
    もし サーバーコンフィグレータが Lucie サーバを初期化した
    ならば 設定リポジトリ用ディレクトリが Lucie サーバ上に生成されない
