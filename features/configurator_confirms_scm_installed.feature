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

    例:
      | SCM        |
      | mercurial  |
      | subversion |
      | git        |

  テンプレ: SCM がインストールされていない
    前提 バックエンドとして <SCM> を指定したコンフィグレータ
    かつ その SCM がインストールされていない
    もし コンフィグレータが SCM のインストール状況を確認
    ならば エラー "<error>"

    例:
      | SCM        | error                       |
      | mercurial  | mercurial is not installed  |
      | subversion | subversion is not installed |
      | git        | git is not installed        |

  シナリオ: SCM が指定されていない
    前提 バックエンドの SCM が指定されていないコンフィグレータ
    もし コンフィグレータが SCM のインストール状況を確認
    ならば エラーが発生しない
