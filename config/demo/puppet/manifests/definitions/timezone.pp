class timezone {
  package { "tzdata":
    ensure => installed
  }

  file { "/etc/localtime":
    source => "file:///usr/share/zoneinfo/Asia/Tokyo",
    require => Package[ "tzdata" ]
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
