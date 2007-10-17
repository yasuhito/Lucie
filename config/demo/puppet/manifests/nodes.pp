node default {
  # ユーザの定義
  include admin_users
  include users
  include disabled_users

  # ソフトウェアごとの設定
  include sudo
  include timezone

  $ganglia_cluster_name = "My Cluster"
  $ganglia_trusted_hosts = "192.168.0.1, 192.168.0.2"
  include ganglia
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
