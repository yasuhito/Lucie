# users/users_list.pp にリストアップされたユーザをグループ化し、パスワー
# ドを設定します。
#
# グループ名は 'class' に続く名前 (ex. admin_users, disabled_users) で
# 表されます。このグループは site.pp 中から include されます。include
# されたグループに含まれるユーザのみが実際に作成されます。


# 管理ユーザ
class admin_users {
  enable_user { "root":
    password_hash => 'h29SP9GgVbLHE'
  }

  enable_user { "yasuhito":
    password_hash => 'h29SP9GgVbLHE'
  }
}


# 一般ユーザ
class users {
  enable_user { "miyasaka":
    password_hash => 'h29SP9GgVbLHE'
  }
}


# 無効にしたいユーザ
class disabled_users {
  disable_user { "bad": }
  disable_user { "evil": }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
