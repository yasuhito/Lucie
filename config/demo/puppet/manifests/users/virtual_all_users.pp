class virtual_all_users {
  @user { "aguy":
    ensure  => "present",
    uid     => "1001",
    gid     => "1001",
    comment => "Andrew Guy",
    home    => "/afs/ir/users/a/g/aguy",
    shell   => "/bin/bash",
  }

  @user { "agirl":
    ensure  => "present",
    uid     => "1002",
    gid     => "137",
    comment => "Anita Girl",
    home    => "/afs/ir/users/a/g/agirl",
    shell   => "/bin/zsh",
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8
### indent-tabs-mode: nil
### End:
