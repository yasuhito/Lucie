class ganglia {
  package { 'ganglia-monitor':
    ensure => installed
  }

  file { '/etc/gmond.conf':
    owner => root,
    group => root,
    mode => 644,
    content => template( "ganglia/gmond.conf.erb" ),
    require => Package[ "ganglia-monitor" ]
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
