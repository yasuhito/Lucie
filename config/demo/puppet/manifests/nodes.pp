node default {
  # ユーザの定義
  include admin_users
  include users
  include disabled_users

  # ソフトウェア設定の定義
  include sudo
}


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
