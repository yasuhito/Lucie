require "lucie/io"
require "lucie/server"
require "nfsroot"


class Service
  class Installer < Service
    include Lucie::IO


    def setup nodes, installer
      info "Setting up installer ..."
      unless FileTest.directory?( Nfsroot.path( installer ) )
        installer.build server_ip_address_for( nodes ), @options, @messenger
      end
    end


    ############################################################################
    private
    ############################################################################


    def server_ip_address_for nodes
      @options[ :dry_run ] ? dummy_ip_address : Lucie::Server.ip_address_for( nodes )
    end


    def dummy_ip_address
      "192.168.0.1"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
