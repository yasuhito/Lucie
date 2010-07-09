# language: ja
機能: パスワードファイルの暗号化と復号

  script/{encrypt,decrypt} コマンドは、
  node install コマンドの --secret に渡すパスワードファイルを生成するために、
  パスワードファイルを正しく暗号化 & 復号できる必要がある


  シナリオ: 暗号化
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (パスワード = "alpine") で暗号化した
    ならば encrypt コマンドは成功する


  シナリオ: ecnrypt のヘルプメッセージ (--help)
    もし encrypt --help コマンドを実行
    ならば 次の出力を得る:
      """
      usage: encrypt [OPTIONS ...] <FILE>

      Options:
        -p, --password [STRING]     A password to encrypt input file

        -h, --help                  Show this help message.
        -d, --dry-run               Print the commands that would be executed, but do not execute them.
        -v, --verbose               Be verbose.
      """


  シナリオ: ecnrypt のヘルプメッセージ (引数無し)
    もし encrypt コマンドに引数を付けずに実行
    ならば 次の出力を得る:
      """
      usage: encrypt [OPTIONS ...] <FILE>

      Options:
        -p, --password [STRING]     A password to encrypt input file

        -h, --help                  Show this help message.
        -d, --dry-run               Print the commands that would be executed, but do not execute them.
        -v, --verbose               Be verbose.
      """


  シナリオ: 復号
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (パスワード = "alpine") で暗号化した
    もし その出力を decrypt コマンドで復号 (パスワード = "alpine" ) した
    ならば decrypt コマンドは成功する
    かつ 出力 "himitsu" を得る


  シナリオ: decrypt のヘルプメッセージ (--help)
    もし decrypt --help コマンドを実行
    ならば 次の出力を得る:
      """
      usage: decrypt [OPTIONS ...] <FILE>

      Options:
        -p, --password [STRING]          A password to decrypt input file

        -h, --help                       Show this help message.
        -d, --dry-run                    Print the commands that would be executed, but do not execute them.
        -v, --verbose                    Be verbose.
      """


  シナリオ: decrypt のヘルプメッセージ (引数無し)
    もし decrypt コマンドに引数を付けずに実行
    ならば 次の出力を得る:
      """
      usage: decrypt [OPTIONS ...] <FILE>

      Options:
        -p, --password [STRING]          A password to decrypt input file

        -h, --help                       Show this help message.
        -d, --dry-run                    Print the commands that would be executed, but do not execute them.
        -v, --verbose                    Be verbose.
      """