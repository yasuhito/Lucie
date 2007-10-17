class admin_users {
  realize_and_set_password { "root":
    password_hash => 'h29SP9GgVbLHE'
  }

  realize_and_set_password { "awfief":
    password_hash => 'h29SP9GgVbLHE'
  }
}


class not_users {
  realize_and_set_password { "bad":
    password_hash => '!!'
  }

  realize_and_set_password { "evil":
    password_hash => '!!'
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
