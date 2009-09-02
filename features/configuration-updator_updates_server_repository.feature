# language: ja
機能: コンフィグレーションアップデータが Lucie サーバ上の設定リポジトリを更新する

  コンフィグレーションアップデータは
  クライアント上の設定リポジトリを更新するために
  まずサーバ上の設定リポジトリを更新する

  背景:
    前提 Lucie のテンポラリディレクトリは "/tmp/lucie"

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
      かつ コンフィグレータがその設定リポジトリを Lucie サーバの "/repos/yasuhito_repos" に複製
      かつ <SCM> が Lucie サーバにインストールされていない
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
    ならば エラー "<ERROR>"

    例:
      | SCM        | ERROR                                                               |
      | Mercurial  | Failed to update /repos/yasuhito_repos: Mercurial is not installed  |
      | Subversion | Failed to update /repos/yasuhito_repos: Subversion is not installed |
      | Git        | Failed to update /repos/yasuhito_repos: Git is not installed        |


  テンプレ: エラー 「サーバ上に設定リポジトリが複製されていない」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ <SCM> が Lucie サーバにインストールされている
      かつ その設定リポジトリが Lucie サーバ上に複製されていない
    もし コンフィグレーションアップデータが Lucie サーバの更新を実行 (ノードに "yasuhito_node" を指定)
    ならば エラー "Configuration repository for yasuhito_node not found on Lucie server."

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
