# language: ja
機能: コンフィグレータが設定プロセスを開始する

  コンフィグレータとして
  設定リポジトリの内容を Lucie クライアントに反映するために
  設定プロセスを開始したい

  シナリオ: 設定プロセスを開始
    前提 ドライランモードがオン
    かつ 冗長モードがオン
    かつ コンフィグレータ
    かつ 設定リポジトリがクライアント (IP アドレスは "192.168.0.1") 上にすでに存在
    もし コンフィグレータが設定プロセスを開始した
    ならば 設定ツールが実行される
