# language: ja
機能: コンフィグレータが Lucie クライアントを初期化する

  コンフィグレータは
  設定リポジトリを各ノードに配置するために
  クライアント上に必要な環境の初期化をしたい

  背景:
    前提 ドライランモードがオン
    かつ 冗長モードがオン
    かつ コンフィグレータ

  シナリオ: 設定リポジトリ用ディレクトリの生成
    前提 設定リポジトリ用ディレクトリがクライアント上に存在しない
    もし コンフィグレータがクライアント (IP アドレスは "192.168.0.1") を初期化した
    ならば 設定リポジトリ用ディレクトリがクライアント上に生成される

  シナリオ: 設定リポジトリ用ディレクトリの生成をスキップ
    前提 設定リポジトリ用ディレクトリがクライアント上にすでに存在
    もし コンフィグレータがクライアント (IP アドレスは "192.168.0.1") を初期化した
    ならば 設定リポジトリ用ディレクトリがクライアント上に生成されない
