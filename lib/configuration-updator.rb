require "configuration-updator/client"
require "configuration-updator/server"


class ConfigurationUpdator
  def initialize debug_options
    @debug_options = debug_options
    @server = Server.new( @debug_options )
    @client = Client.new( @debug_options )
  end


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      @server.update each
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def repositories_for nodes
    list = nodes.collect do | each |
      begin
        @client.repository_name_for each.ip_address
      rescue
        raise "Configuration repository for #{ each.name } not found on Lucie server."
      end
    end
    list.uniq
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
