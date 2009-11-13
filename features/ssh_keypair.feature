# language: ja
機能: SSH のキーペアの自動生成と認証

  Lucie のインストールコマンドは
  ユーザが SSH キーの生成や authorized_keys への登録を手動で行わなくても済むように
  SSH のキーペアを必要に応じて生成し、authorized_keys に登録する

  テンプレ: SSH キーペアの自動生成
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアが "<ホームディレクトリのキーペア>"
    かつ Lucie ディレクトリ "/tmp/lucie" に SSH のキーペアが "<Lucie ディレクトリのキーペア>"
    もし SSH のキーペアを生成しようとした
    ならば SSH のキーペアは "<キーペアの生成>"

  サンプル:
    | ホームディレクトリのキーペア | Lucie ディレクトリのキーペア | キーペアの生成 |
    | 存在する                     | 存在する                     | 生成されない   |
    | 存在しない                   | 存在する                     | 生成されない   |
    | 存在する                     | 存在しない                   | 生成されない   |
    | 存在しない                   | 存在しない                   | 生成される     |

  シナリオ: authorized_keys が無い場合、公開鍵をコピー
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアがすでに存在
    かつ Lucie ディレクトリ "/tmp/lucie" に SSH のキーペアが存在しない
    かつ authorized_keys が存在しない
    もし SSH のキーペアを生成しようとした
    ならば ホームディレクトリの公開鍵が authorized_keys にコピーされる

  シナリオ: authorized_keys があるけど公開鍵が登録されていない場合、公開鍵を追加
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアがすでに存在
    かつ Lucie ディレクトリ "/tmp/lucie" に SSH のキーペアが存在しない
    かつ 空の authorized_keys が存在
    もし SSH のキーペアを生成しようとした
    ならば ホームディレクトリの公開鍵が authorized_keys に追加される
