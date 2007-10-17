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

  service { 'gmond':
    enable => true,
    ensure => running,
    require => [ Package[ 'ganglia-monitor' ], File[ '/etc/gmond.conf' ] ],
    subscribe => [ Package[ 'ganglia-monitor' ], File[ '/etc/gmond.conf' ] ],
    restart => '/etc/init.d/ganglia-monitor restart'
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
