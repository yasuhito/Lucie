# language: ja
機能: パスワードファイルの暗号化と復号

  script/{encrypt,decrypt} コマンドは、
  node install コマンドの --secret に渡すパスワードファイルを生成するために、
  パスワードファイルを正しく暗号化 & 復号できる必要がある

  シナリオ: 暗号化
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (パスワード = "alpine") で暗号化した
    ならば encrypt コマンドは成功する

  シナリオ: 復号
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (パスワード = "alpine") で暗号化した
    もし その出力を decrypt コマンドで復号 (パスワード = "alpine" ) した
    ならば decrypt コマンドは成功する
    かつ 出力 "himitsu" を得る

