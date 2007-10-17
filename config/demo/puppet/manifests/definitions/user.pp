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

  # [HACK]: netinfo 以外の provider ではパスワード管理をサポートしていないので、/etc/shadow を直接編集
  set_password { $name:
    hash => $password_hash
  }

  # [HACK]: puppet 0.20.1 の #380 (http://reductivelabs.com/trac/puppet/ticket/380) を回避
  # 本来なら、user type の managehome プロパティでホームディレクトリを作成してしまいたい
  exec { "addgroup $name":
    unless => "grep -qe '^$name[[:space:]]*:' -- /etc/group",
    path =>  "/bin:/usr/sbin",
    alias => "addgroup_$name"
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
