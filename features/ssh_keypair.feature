# language: ja
機能: SSH のキーペアの自動的な管理

  Lucie のインストールコマンドは
  ユーザが SSH キーの生成や登録を手動で行わなくても済むように
  SSH のキーペアを必要に応じて生成し、authorized_keys に登録する

  シナリオ: すでに $HOME/.ssh/{id_rsa,id_rsa.pub} がある場合、生成しない
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアがすでに存在
    もし SSH のキーペアを生成しようとした
    ならば SSH のキーペアは生成されない

  シナリオ: $HOME/.ssh/{id_rsa,id_rsa.pub} が無い場合、生成する
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアが存在しない
    もし SSH のキーペアを生成しようとした
    ならば Lucie ディレクトリ以下に SSH のキーペアが生成される

  シナリオ: authorized_keys が無い場合、公開鍵をコピー
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアがすでに存在
    かつ authorized_keys が存在しない
    もし SSH のキーペアを生成しようとした
    ならば 公開鍵が authorized_keys にコピーされる

  シナリオ: authorized_keys があるけど公開鍵が登録されていない場合、公開鍵を追加
    前提 ホームディレクトリ "/tmp/yasuhito" に SSH のキーペアがすでに存在
    かつ 空の authorized_keys が存在
    もし SSH のキーペアを生成しようとした
    ならば 公開鍵が authorized_keys に追加される
