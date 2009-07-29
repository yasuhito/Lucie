# language: ja
機能: コンフィグレータは SCM が Lucie サーバにインストールされていることを確認する

  コンフィグレータは
  設定リポジトリを Lucie サーバにチェックアウトするために
  指定された SCM が Lucie サーバにインストールされているかどうかを確認する

  テンプレ: SCM がインストールされている
    前提 バックエンドとして <SCM> を指定したコンフィグレータ
    かつ その SCM がインストールされている
    もし コンフィグレータが SCM のインストール状況を確認
    ならば エラーが発生しない
    かつ メッセージ "<message>"

    例:
      | SCM        | message                           |
      | mercurial  | Checking mercurial ... INSTALLED  |
      | subversion | Checking subversion ... INSTALLED |

  テンプレ: SCM がインストールされていない
    前提 バックエンドとして <SCM> を指定したコンフィグレータ
    かつ その SCM がインストールされていない
    もし コンフィグレータが SCM のインストール状況を確認
    ならば メッセージ "<message>"
    かつ エラー "<error>"

    例:
      | SCM        | message                               | error                       |
      | mercurial  | Checking mercurial ... NOT INSTALLED  | mercurial is not installed  |
      | subversion | Checking subversion ... NOT INSTALLED | subversion is not installed |

  シナリオ: SCM が指定されていない
    前提 コンフィグレータ
    もし コンフィグレータが SCM のインストール状況を確認
    ならば エラーが発生しない
    かつ メッセージは空
