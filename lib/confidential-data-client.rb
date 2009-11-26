require "lucie"
require "ssh"


class ConfidentialDataClient
  def initialize debug_options
    @ssh = SSH.new( debug_options )
  end


  def install client_ip, server_ip, target
    @ssh.cp "#{ Lucie::ROOT }/script/get_confidential_data", "root@#{ client_ip }:#{ target }"
    @ssh.sh client_ip, "sed -i s/USER/#{ ENV[ 'USER' ] }/ #{ target }"
    @ssh.sh client_ip, "sed -i s/SERVER/#{ server_ip }/ #{ target }"
    @ssh.sh client_ip, "chmod +x #{ target }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

