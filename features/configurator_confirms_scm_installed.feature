# language: ja
機能: コンフィグレータは SCM がインストールされていることを確認する

  コンフィグレータは
  リポジトリをサーバ上にチェックアウトするために
  サーバ上に指定された SCM がインストールされているかどうかを確認する

  シナリオ: SCM が指定されていない
    前提 コンフィグレータ
    もし コンフィグレータが SCM を確認
    ならば エラーが発生しない
    かつ メッセージは空

  テンプレ: SCM がインストールされている
    前提 SCM として <SCM> を選択
    かつ コンフィグレータ
    かつ SCM がインストールされている
    もし コンフィグレータが SCM を確認
    ならば エラーが発生しない
    かつ メッセージ "<message>"

    例:
      | SCM        | message                           |
      | mercurial  | Checking mercurial ... INSTALLED  |
      | subversion | Checking subversion ... INSTALLED |

  テンプレ: SCM がインストールされていない
    前提 SCM として <SCM> を選択
    かつ コンフィグレータ
    かつ SCM がインストールされていない
    もし コンフィグレータが SCM を確認
    ならば メッセージ "<message>"
    かつ エラー "<error>"

    例:
      | SCM        | message                               | error                       |
      | mercurial  | Checking mercurial ... NOT INSTALLED  | mercurial is not installed  |
      | subversion | Checking subversion ... NOT INSTALLED | subversion is not installed |
