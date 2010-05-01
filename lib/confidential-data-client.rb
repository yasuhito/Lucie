require "confidential-data-server"
require "lucie"
require "lucie/utils"
require "ssh"


class ConfidentialDataClient
  include Lucie::Utils


  def initialize client_ip, server_ip, debug_options
    @client_ip = client_ip
    @server_ip = server_ip
    @debug_options = debug_options
    @ssh = SSH.new( nil, @debug_options )
  end


  def install
    create_bin_directory unless bin_directory_exists?
    scp_to_node
    chmod_x
  end


  ##############################################################################
  private
  ##############################################################################


  def path
    File.join bin_directory, "get_confidential_data"
  end


  def scp_to_node
    @ssh.cp tempfile( <<-EOF ).path, "root@#{ @client_ip }:#{ path }"
#!/bin/sh
ssh -oStrictHostKeyChecking=no #{ ENV[ 'USER' ] }@#{ @server_ip } 'telnet 127.0.0.1 #{ ConfidentialDataServer::PORT }'
EOF
  end


  def chmod_x
    @ssh.sh @client_ip, "chmod +x #{ path }"
  end


  def bin_directory
    "/var/lib/lucie/bin"
  end


  def bin_directory_exists?
    @ssh.sh @client_ip, "test -d #{ bin_directory }" rescue nil
  end


  def create_bin_directory
    @ssh.sh @client_ip, "mkdir -p #{ bin_directory }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

