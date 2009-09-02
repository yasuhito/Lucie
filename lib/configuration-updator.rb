require "configuration-updator/client"
require "configuration-updator/server"
require "lucie/logger/null"


class ConfigurationUpdator
  def initialize debug_options = {}
    @server = Server.new( debug_options )
    @client = Client.new( debug_options )
  end


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      begin
        @server.update each
      rescue => e
        raise "Failed to update #{ each }: #{ e.message }"
      end
    end
  end


  def update_client node
    begin
      @client.update node, @server.local_clone_directory( @client.repository_name_for node )
    rescue => e
      raise "Failed to update #{ node.name }: #{ e.message }"
    end
  end


  def start node, logger = Lucie::Logger::Null.new
    @client.start node, logger
  end


  ##############################################################################
  private
  ##############################################################################


  def repositories_for nodes
    list = nodes.collect do | each |
      @client.repository_name_for each
    end
    list.uniq
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
