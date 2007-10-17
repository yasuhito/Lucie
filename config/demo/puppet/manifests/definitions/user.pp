define set_password( $hash ) {
  ensure_key_value { "set_pass_$name":
    file      => '/etc/shadow',
    key       => $name,
    value     => "$hash:13572:0:99999:7:::",
    delimiter => ':'
  }
}


define realize_and_set_password( $password_hash ) {
  realize User[ $name ]

  set_password { $name:
    hash => $password_hash
  }

  file { "/home/$name":
    ensure => directory,
    require => User[ $name ]
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
