# language: ja
機能: コンフィグレーションアップデータが Lucie クライアント上の設定リポジトリを更新する

  コンフィグレーションアップデータは
  クライアントの設定を更新するために
  クライアント上の設定リポジトリを更新する

  背景:
    前提 eth0 "192.168.0.1"
    かつ a node named "yasuhito_node", with IP address "192.168.0.100"


  テンプレ: クライアント上の設定リポジトリを更新
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie クライアント "yasuhito_node" に複製
      かつ <SCM> が Lucie クライアントにインストールされている
    もし コンフィグレーションアップデータが Lucie クライアント "yasuhito_node" の更新を実行
    ならば エラーが発生しない
      かつ Lucie クライアント上のそのリポジトリが "<COMMANDS>" コマンドで更新される

    例:
      | SCM         | COMMANDS             |
      | Subversion  | rsync                |
      | Mercurial   | hg pull, hg update   |
      | Git         | git pull, git update |


  テンプレ: エラー「SCM がインストールされていない」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie クライアント "yasuhito_node" に複製
      かつ <SCM> が Lucie クライアントにインストールされていない
    もし コンフィグレーションアップデータが Lucie クライアント "yasuhito_node" の更新を実行
    ならば エラー "<ERROR>"

    例:
      | SCM         | ERROR                                                                        |
      | Subversion  | Failed to update yasuhito_node: Subversion is not installed on yasuhito_node |
      | Mercurial   | Failed to update yasuhito_node: Mercurial is not installed on yasuhito_node  |
      | Git         | Failed to update yasuhito_node: Git is not installed on yasuhito_node        |

  テンプレ: エラー「クライアント上に設定リポジトリが複製されていない」
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie クライアント "yasuhito_node" に複製していない
      かつ <SCM> が Lucie クライアントにインストールされている
    もし コンフィグレーションアップデータが Lucie クライアント "yasuhito_node" の更新を実行
    ならば エラー "Failed to find LDB repository on yasuhito_node. Try node update with `--source-control' and `--ldb-repository'"

    例:
      | SCM        |
      | Mercurial  |
      | Subversion |
      | Git        |
