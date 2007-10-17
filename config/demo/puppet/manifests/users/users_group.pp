# users/users_list.pp にリストアップされたユーザをグループ化し、パスワー
# ドを設定します。
#
# グループ名は 'class' に続く名前 (ex. admin_users, disabled_users) で
# 表されます。このグループ名は site.pp から "include [グループ名]" のよ
# うに参照されます。


class admin_users {
  enable_user { "root":
    password_hash => 'h29SP9GgVbLHE'
  }

  enable_user { "awfief":
    password_hash => 'h29SP9GgVbLHE'
  }
}


class disabled_users {
  disable_user { "bad": }
  disable_user { "evil": }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
