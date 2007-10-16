class sudo {
  case $operatingsystem {
    default: {
      # sudo パッケージがインストールされていることを保証
      package { 'sudo':
        ensure => installed
      }
    }
  }

  # /etc/sudoers を puppet/files/sudoers からコピーし、適切なパーミッションを設定
  file { 'sudoers':
    path => $operatingsystem ? {
      default => '/etc/sudoers'
    },
    source => 'puppet://lucie-server.localdomain.com/files/sudoers',
    mode => 0440,
    owner => root,
    group => $operatingsystem ? {
      default => root
    }
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
