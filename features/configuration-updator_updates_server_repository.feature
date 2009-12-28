# language: ja
機能: コンフィグレーションアップデータが Lucie サーバ上の設定リポジトリを更新する

  コンフィグレーションアップデータは
  クライアント上の設定リポジトリを更新するために
  まずサーバ上の設定リポジトリを更新する

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie/"
    かつ eth0 "192.168.0.1"
    かつ a node named "yasuhito_node", with IP address "192.168.0.100"

  テンプレ: サーバ上の設定リポジトリを更新
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie サーバに複製
      かつ <SCM> が Lucie サーバにインストールされている
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
    ならば エラーが発生しない
      かつ Lucie サーバの設定リポジトリが "<COMMANDS>" コマンドで更新される

    例:
      | SCM         | COMMANDS             |
      | Subversion  | svn update           |
      | Mercurial   | hg pull, hg update   |
      | Git         | git pull, git update |


  テンプレ: エラー 「SCM がインストールされていない」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie サーバに複製
      かつ <SCM> が Lucie サーバにインストールされていない
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
    ならば エラー "<ERROR>"

    例:
      | SCM        | ERROR                                                               |
      | Mercurial  | Failed to update /tmp/lucie/config/REPOSITORY: Mercurial is not installed  |
      | Subversion | Failed to update /tmp/lucie/config/REPOSITORY: Subversion is not installed |
      | Git        | Failed to update /tmp/lucie/config/REPOSITORY: Git is not installed        |


  テンプレ: エラー 「サーバ上に設定リポジトリが複製されていない」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ <SCM> が Lucie サーバにインストールされている
      かつ その設定リポジトリが Lucie サーバ上に複製されていない
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
    ならば エラー "Failed to update /tmp/lucie/config/REPOSITORY: Configuration repository /tmp/lucie/config/REPOSITORY not found on Lucie server."

    例:
      | SCM        |
      | Mercurial  |
      | Subversion |
      | Git        |


  テンプレ: エラー 「SCM の更新コマンドが失敗」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie サーバに複製
      かつ <SCM> が Lucie サーバにインストールされている
      かつ <SCM> が壊れている
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
      ならば エラー

    例:
      | SCM        |
      | Mercurial  |
      | Subversion |
      | Git        |
