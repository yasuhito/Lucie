define set_password( $hash ) {
  ensure_key_value { "set_password_$name":
    file      => '/etc/shadow',
    key       => $name,
    value     => "$hash:13572:0:99999:7:::",
    delimiter => ':'
  }
}


define enable_user( $password_hash ) {
  realize User[ $name ]

  set_password { $name:
    hash => $password_hash
  }

  # puppet 0.20.1 の #380 を回避
  exec { "addgroup $name":
    unless => "grep -qe '^$name[[:space:]]*:' -- /etc/group",
    path =>  "/bin:/usr/sbin"
  }

  $home_dir = $name ? {
    root => "/root",
    default => "/home/$name"
  }

  file { $home_dir:
    ensure => directory,
    require => [ User[ $name ], exec[ "addgroup $name" ] ],
    owner => $name,
    group => $name
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
