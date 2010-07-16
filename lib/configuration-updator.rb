require "configuration-updator/client"
require "configuration-updator/server"
require "lucie/debug"
require "lucie/logger"


class ConfigurationUpdator
  include Lucie::Debug


  def initialize debug_options = {}
    @debug_options = debug_options
    @server = Server.new( @debug_options )
    @client = Client.new( @debug_options )
  end


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      debug "Updating server repository #{ each } ..."
      @server.update each
    end
  end


  def update_client node
    debug "Updating client repository on node #{ node.name } ..."
    @client.update node, server_repository_path( node )
  end


  def start node, logger = Lucie::Logger::Null.new
    debug "Starting LDB on node #{ node.name } ..."
    @client.start node, logger
  end


  ##############################################################################
  private
  ##############################################################################


  def server_repository_path node
    @server.local_clone_directory @client.repository_name_of( node )
  end


  def repositories_for nodes
    list = nodes.collect do | each |
      debug "Searching current configuration repository on node #{ each.name } ..."
      repos = @client.repository_name_of( each )
      debug "Current configuration repository on node #{ each.name } is #{ repos }"
      repos
    end
    list.uniq
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
