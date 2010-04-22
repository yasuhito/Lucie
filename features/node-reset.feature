# language: ja
機能: デーモンのリセットコマンド

  ユーザは
  インストールを中断してデーモンが中途半端な状態になったのをリセットするために
  node reset コマンドを実行する

  シナリオ: リセット
    前提 TFTP のルートパスは "/tmp/tftproot"
    かつ ファイル "/tmp/tftproot/pxelinux.cfg/01-40-61-86-06-4c-86" が存在
    かつ ファイル "/tmp/tftproot/pxelinux.cfg/01-40-61-86-0c-8e-f4" が存在
    もし node reset コマンドを実行した
    ならば 次の出力を得る:
      """
      file write (/tmp/tftproot/pxelinux.cfg/01-40-61-86-06-4c-86)
      > default local
      > 
      > label local
      > localboot 0
      file write (/tmp/tftproot/pxelinux.cfg/01-40-61-86-0c-8e-f4)
      > default local
      > 
      > label local
      > localboot 0
      """
