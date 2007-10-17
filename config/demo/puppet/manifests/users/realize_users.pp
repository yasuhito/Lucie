class admin_users {
  enable_user { "root":
    password_hash => 'h29SP9GgVbLHE'
  }

  enable_user { "awfief":
    password_hash => 'h29SP9GgVbLHE'
  }
}


class not_users {
  enable_user { "bad":
    password_hash => '!!'
  }

  enable_user { "evil":
    password_hash => '!!'
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
