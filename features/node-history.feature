# language: ja
機能: インストールログの履歴コマンド

  ユーザは
  インストールの履歴を確認するために
  node history コマンドを実行する

  シナリオ: 履歴の表示
    前提 ノード "yasuhito" のログディレクトリは "/tmp/yasuhito"
    かつ インストール 1 回目は 1800 秒かかって成功
    かつ インストール 2 回目は 92 秒かかって失敗
    かつ インストール 3 回目は 1900 秒かかって成功
    かつ インストール 4 回目は 270 秒かかって失敗
    かつ インストール 5 回目は実行中
    もし ノード "yasuhito" に対して node history コマンドを実行した
    ならば 次の出力を得る:
      """
      install #1: success in 1800 sec.
      install #2: failed in 92 sec.
      install #3: success in 1900 sec.
      install #4: failed in 270 sec.
      install #5: incomplete.
      """

  シナリオ: ログが壊れていた場合
    前提 ノード "yasuhito" のログディレクトリは "/tmp/yasuhito"
    かつ インストール 1 回目は 1800 秒かかって成功
    かつ インストール 2 回目は 92 秒かかって失敗
    かつ インストール 3 回目は 1900 秒かかって成功
    かつ インストール 4 回目のログが消失
    かつ インストール 5 回目は実行中
    もし ノード "yasuhito" に対して node history コマンドを実行した
    ならば 次の出力を得る:
      """
      install #1: success in 1800 sec.
      install #2: failed in 92 sec.
      install #3: success in 1900 sec.
      Failed to parse install #4 log. Skipping ...
      install #5: incomplete.
      """

  シナリオ: 履歴の表示 (カラー)
    前提 ノード "yasuhito" のログディレクトリは "/tmp/yasuhito"
    かつ インストール 1 回目は 1800 秒かかって成功
    かつ インストール 2 回目は 92 秒かかって失敗
    かつ インストール 3 回目は 1900 秒かかって成功
    かつ インストール 4 回目のログが消失
    かつ インストール 5 回目は実行中
    もし ノード "yasuhito" に対して node history コマンドを --color オプション付きで実行した
    ならば 次の出力を得る:
      """
      [32minstall #1: success in 1800 sec.[0m
      [31minstall #2: failed in 92 sec.[0m
      [32minstall #3: success in 1900 sec.[0m
      [33mFailed to parse install #4 log. Skipping ...[0m
      install #5: incomplete.
      """

