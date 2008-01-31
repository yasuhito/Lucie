class ssh {
  case $operatingsystem {
    default: {
      # ssh パッケージがインストールされていることを保証
      package { 'ssh':
        ensure => installed
      }
    }
  }
}