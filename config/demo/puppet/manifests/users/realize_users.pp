class admin_users {
  realize(
    User["root"],
    User["awfief"]
  )

  setpass { "root":
    hash => 'q1w2e3r4t5y6u7i8o9p0'
  }

  setpass { "awfief":
    hash => 'a1s2d3f4g5h6j7k8l9!0'
  }
}


class not_users {
  realize(
    User["bad"],
    User["evil"],
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
### coding: utf-8
### indent-tabs-mode: nil
### End:
