# language: ja
機能: パスワードファイルの暗号化と復号

  encrypt コマンドは、
  node install コマンドの --secret に渡すパスワードファイルを生成するために、
  パスワードファイルを正しく暗号化できる必要がある


  シナリオ: 暗号化 (--password)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "--password alpine") で暗号化した
    ならば encrypt コマンドは成功する


  シナリオ: 暗号化 (-p)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "-p alpine") で暗号化した
    ならば encrypt コマンドは成功する


  シナリオ: encrypt をドライラン (--dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "--dry-run --password alpine") で暗号化した
    ならば encrypt コマンドは成功する
    かつ encrypt コマンドの標準出力は無し


  シナリオ: encrypt をドライラン (-d)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "-d --password alpine") で暗号化した
    ならば encrypt コマンドは成功する
    かつ encrypt コマンドの標準出力は無し


  シナリオ: encrypt を冗長オプション付きでドライラン (--verbose --dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "--verbose --dry-run --password alpine") で暗号化した
    ならば encrypt コマンドは成功する
    かつ encrypt コマンドの標準出力は無し
    かつ encrypt コマンドの標準エラー出力は "openssl enc -pass pass:'alpine' -e -aes256 -in .*" にマッチ


  シナリオ: encrypt を冗長オプション付きでドライラン (-v --dry-run)
    前提 中身が "himitsu" の一時ファイルが存在
    もし その一時ファイルを encrypt コマンド (オプションは "-v --dry-run --password alpine") で暗号化した
    ならば encrypt コマンドは成功する
    かつ encrypt コマンドの標準出力は無し
    かつ encrypt コマンドの標準エラー出力は "openssl enc -pass pass:'alpine' -e -aes256 -in .*" にマッチ


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


  シナリオ: ecnrypt のヘルプメッセージ (-h)
    もし encrypt -h コマンドを実行
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
