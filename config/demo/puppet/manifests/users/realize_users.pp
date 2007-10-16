class admin_users {
  realize(
    User["root"],
    User["awfief"]
  )

  setpass { "root":
    hash => 'h29SP9GgVbLHE'
  }

  setpass { "awfief":
    hash => 'h29SP9GgVbLHE'
  }
}


class not_users {
  realize(
    User["bad"],
    User["evil"]
  )

  setpass { "bad":
    hash  => '!!'
  }

  setpass { "evil":
    hash  => '!!'
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
