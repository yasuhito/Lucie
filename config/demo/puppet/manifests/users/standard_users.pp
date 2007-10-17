@user { "root":
  ensure      =>  "present",
  uid         =>  "0",
  gid         =>  "root",
  comment     =>  "root",
  home        =>  "/root",
  shell       =>  "/bin/sh",
  require     =>  exec[ "addgroup_root" ]
}


@user { "awfief":
  ensure      =>  "present",
  uid         =>  "10001",
  gid         =>  "awfief",
  groups      =>  [ "awfief", "operator" ],
  comment     =>  "Sheeri Kritzer",
  home        =>  "/home/awfief",
  shell       =>  "/bin/bash",
  require     =>  exec[ "addgroup_awfief" ]
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
