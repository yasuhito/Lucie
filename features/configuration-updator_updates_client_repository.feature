# language: ja
機能: コンフィグレーションアップデータが Lucie クライアント上の設定リポジトリを更新する

  コンフィグレーションアップデータは
  クライアントの設定を更新するために
  クライアント上の設定リポジトリを更新する

  テンプレ: クライアント上の設定リポジトリを更新
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (<SCM>)
      かつ コンフィグレータがその設定リポジトリを Lucie クライアント "yasuhito_node" に複製
      かつ <SCM> が Lucie クライアントにインストールされている
    もし コンフィグレーションアップデータが Lucie クライアント "yasuhito_node" の更新を実行
    ならば Lucie クライアント上のそのリポジトリが "<COMMANDS>" コマンドで更新される

    例:
      | SCM         | COMMANDS             |
      | Subversion  | scp                  |
      | Mercurial   | hg pull, hg update   |
      | Git         | git pull, git update |
