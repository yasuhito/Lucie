class absent_users {
  @user { "bad":
    ensure     => "absent",
    uid        => "502",
    gid        => "wheel",
    comment    => "bad user no biscuit",
    home       => "/home/bad",
    shell      => "/bin/bash",
    managehome =>  "true"
  }

  @user { "evil":
    ensure     => "absent",
    uid        => "503",
    gid        => "wheel",
    comment    => "evil",
    home       => "/home/evil",
    shell      => "/bin/bash",
    managehome =>  "true"
  }
}
