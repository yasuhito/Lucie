# language: ja
機能: サブプロセスの起動

  Lucie の各モジュールは
  インストール処理などを実行するために
  サブプロセスを起動し標準出力や標準エラー出力、および終了コードを取得する

  シナリオ: サブプロセスの終了コードを取得 (サブプロセスが成功した場合)
    もし サブプロセス "true" を実行
    ならば 終了コード "0" が返る

  シナリオ: サブプロセスの終了コードを取得 (サブプロセスが失敗した場合)
    もし サブプロセス "false" を実行
    ならば 終了コード "1" が返る

  シナリオ: サブプロセスが成功したときの後処理
    もし サブプロセス "true" を実行
    ならば 成功時の後処理が呼ばれる
    かつ 失敗時の後処理は呼ばれない

  シナリオ: サブプロセスが失敗したときの後処理
    もし サブプロセス "false" を実行
    ならば 失敗時の後処理が呼ばれる
    かつ 成功時の後処理は呼ばれない

  シナリオ: サブプロセスの標準出力を取得
    もし サブプロセス "printf 'Hello\nSTDOUT\nWorld!'" を実行
    ならば 次の標準出力を得る:
      """
      Hello
      STDOUT
      World!
      """
    かつ 標準エラー出力には何も得ない

  シナリオ: サブプロセスの標準エラー出力を取得
    もし サブプロセス "printf 'Hello\nSTDERR\nWorld!' >&2" を実行
    ならば 次の標準エラー出力を得る:
      """
      Hello
      STDERR
      World!
      """
    かつ 標準出力には何も得ない
