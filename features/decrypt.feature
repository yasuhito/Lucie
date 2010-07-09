# language: ja
機能: パスワードファイルの復号

  decrypt コマンドは、
  node install コマンドの --secret に渡すパスワードファイルをデバッグするために、
  パスワードファイルを正しく復号できる必要がある


  シナリオ: 復号 (--password)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "--password alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ 出力 "himitsu" を得る


  シナリオ: 復号 (-p)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "-p alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ 出力 "himitsu" を得る


  シナリオ: 復号のドライラン (--dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "--dry-run --password alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ decrypt コマンドの標準出力は無し


  シナリオ: 復号のドライラン (-d)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "-d --password alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ decrypt コマンドの標準出力は無し


  シナリオ: 復号を冗長オプション付きでドライラン (--verbose --dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "--verbose --dry-run --password alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ decrypt コマンドの標準出力は無し
    かつ decrypt コマンドの標準エラー出力は "openssl enc -pass pass:'alpine' -d -aes256 -in .*" にマッチ


  シナリオ: 復号を冗長オプション付きでドライラン (-v --dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    かつ その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    もし その出力を decrypt コマンド (オプションは "-v --dry-run --password alpine" ) で復号した
    ならば decrypt コマンドは成功する
    かつ decrypt コマンドの標準出力は無し
    かつ decrypt コマンドの標準エラー出力は "openssl enc -pass pass:'alpine' -d -aes256 -in .*" にマッチ


  シナリオ: ヘルプメッセージ (--help)
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


  シナリオ: ヘルプメッセージ (-h)
    もし decrypt -h コマンドを実行
    ならば 次の出力を得る:
      """
      usage: decrypt [OPTIONS ...] <FILE>

      Options:
        -p, --password [STRING]          A password to decrypt input file

        -h, --help                       Show this help message.
        -d, --dry-run                    Print the commands that would be executed, but do not execute them.
        -v, --verbose                    Be verbose.
      """


  シナリオ: ヘルプメッセージ (引数無し)
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
