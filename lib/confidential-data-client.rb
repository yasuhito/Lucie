require "lucie"
require "ssh"


class ConfidentialDataClient
  def initialize debug_options
    @ssh = SSH.new( debug_options )
    @path = File.join( bin_directory, "get_confidential_data" )
  end


  def install client_ip, server_ip
    create_bin_directory client_ip unless bin_directory_exists?( client_ip )
    @ssh.cp "#{ Lucie::ROOT }/script/get_confidential_data", "root@#{ client_ip }:#{ @path }"
    @ssh.sh client_ip, "sed -i s/USER/#{ ENV[ 'USER' ] }/ #{ @path }"
    @ssh.sh client_ip, "sed -i s/SERVER/#{ server_ip }/ #{ @path }"
    @ssh.sh client_ip, "chmod +x #{ @path }"
  end


  ##############################################################################
  private
  ##############################################################################


  def bin_directory
    "/var/lib/lucie/bin"
  end


  def bin_directory_exists? ip
    begin
      @ssh.sh ip, "test -d #{ bin_directory }"
      true
    rescue
      return false
    end
  end


  def create_bin_directory client_ip
    @ssh.sh client_ip, "mkdir -p #{ bin_directory }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

