# Lucie で管理したいすべてのユーザをリストアップします。
#
# NOTE: ここにリストアップされたユーザは Puppet に登録されるだけで、こ
# のままでは作成されません。ユーザを実際に作成する方法は
# users/users_group.pp と site.pp を参照してください。
#
# また、各プロパティの意味については次の URL を参照してください。
# http://reductivelabs.com/trac/puppet/wiki/TypeReference#id64


@user { "root":
  ensure      =>  "present",
  uid         =>  "0",
  gid         =>  "root",
  comment     =>  "root",
  home        =>  "/root",
  shell       =>  "/bin/sh",
  require     =>  exec[ "addgroup_root" ]
}


@user { "yasuhito":
  ensure      =>  "present",
  uid         =>  "1000",
  gid         =>  "yasuhito",
  groups      =>  [ "yasuhito", "operator" ],
  comment     =>  "Yasuhito TAKAMIYA",
  home        =>  "/home/yasuhito",
  shell       =>  "/bin/bash",
  require     =>  exec[ "addgroup_yasuhito" ]
}


@user { "miyasaka":
  ensure      =>  "present",
  uid         =>  "1001",
  gid         =>  "miyasaka",
  groups      =>  [ "miyasaka", "users" ],
  comment     =>  "MIYASAKA-san",
  home        =>  "/home/miyasaka",
  shell       =>  "/bin/bash",
  require     =>  exec[ "addgroup_miyasaka" ]
}


@user { "bad":
  ensure     => "absent",
  uid        => "502",
  gid        => "bad",
  comment    => "bad user no biscuit",
  home       => "/home/bad",
  shell      => "/bin/bash"
}


@user { "evil":
  ensure     => "absent",
  uid        => "503",
  gid        => "evil",
  comment    => "evil",
  home       => "/home/evil",
  shell      => "/bin/bash"
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
