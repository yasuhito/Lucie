class admin_users {
  realize_and_set_password { "root":
    hash => 'h29SP9GgVbLHE'
  }

  realize_and_set_password { "awfief":
    hash => 'h29SP9GgVbLHE'
  }
}


class not_users {
  realize_and_set_password { "bad":
    hash => '!!'
  }

  realize_and_set_password { "evil":
    hash => '!!'
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
