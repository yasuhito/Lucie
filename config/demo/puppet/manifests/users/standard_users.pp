@user { "root":
  ensure      =>  "present",
  uid         =>  "0",
  gid         =>  "wheel",
  comment     =>  "root",
  home        =>  "/root",
  shell       =>  "/bin/sh",
  managehome  =>  "true"
}


@user { "awfief":
  ensure      =>  "present",
  uid         =>  "10001",
  gid         =>  "wheel",
  comment     =>  "Sheeri Kritzer",
  home        =>  "/home/awfief",
  shell       =>  "/bin/bash",
  managehome  =>  "true"
}
