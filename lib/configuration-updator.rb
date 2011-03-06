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
    repos = []
    failed_nodes = []

    nodes.each do | each |
      begin
        repos << repository_for( each )
      rescue
        puts $!.to_s
        failed_nodes << each
      end
    end

    repos.uniq.each do | each |
      debug "Updating server repository #{ each } ..."
      @server.update each
    end

    failed_nodes
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


  def repository_for node
    debug "Searching current configuration repository on node #{ node.name } ..."
    repos = @client.repository_name_of( node )
    debug "Current configuration repository on node #{ node.name } is #{ repos }"
    repos
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
