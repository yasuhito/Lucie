# language: ja
機能: サーバーコンフィグレータは SCM が Lucie サーバにインストールされていることを確認する

  サーバーコンフィグレータは
  設定リポジトリを Lucie サーバにチェックアウトするために
  指定された SCM が Lucie サーバにインストールされているかどうかを確認する

  テンプレ: SCM がインストールされている
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ その SCM がインストールされている
    もし サーバーコンフィグレータが SCM のインストール状況を確認
    ならば エラーが発生しない

    例:
      | SCM        |
      | Mercurial  |
      | Subversion |
      | Git        |

  テンプレ: SCM がインストールされていない
    前提 バックエンドとして <SCM> を指定したサーバーコンフィグレータ
    かつ その SCM がインストールされていない
    もし サーバーコンフィグレータが SCM のインストール状況を確認
    ならば エラー "<error>"

    例:
      | SCM        | error                       |
      | Mercurial  | Mercurial is not installed  |
      | Subversion | Subversion is not installed |
      | Git        | Git is not installed        |

  シナリオ: SCM が指定されていない
    前提 バックエンドの SCM が指定されていないサーバーコンフィグレータ
    もし サーバーコンフィグレータが SCM のインストール状況を確認
    ならば エラーが発生しない
