@user { "root":
  ensure      =>  "present",
  uid         =>  "0",
  gid         =>  "root",
  comment     =>  "root",
  home        =>  "/root",
  shell       =>  "/bin/sh"
}


@user { "awfief":
  ensure      =>  "present",
  uid         =>  "10001",
  gid         =>  "operator",
  comment     =>  "Sheeri Kritzer",
  home        =>  "/home/awfief",
  shell       =>  "/bin/bash"
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
