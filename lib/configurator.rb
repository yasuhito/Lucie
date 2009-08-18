require "configurator/client"
require "configurator/server"


class Configurator
  def self.convert url
    url.gsub( /[\/:@]/, "_" )
  end


  def self.guess_scm node, options = {}
    Client.guess_scm node, options
  end


  def initialize scm, options
    @options = options
    @backend = LDB.new( @options, @options[ :messenger ] )
    @client = Client.new( scm, @options )
    @server = Server.new( scm, @options )
  end


  def clone_to_server url, lucie_ip
    @server.setup
    @server.clone url
    @server.clone_clone url, lucie_ip
  end


  def clone_to_client url, node, lucie_ip
    @client.setup node.ip_address
    @client.install lucie_ip, node.ip_address, url
  end


  def update_server url
    @server.update self.class.convert( url )
  end


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      @server.update each
    end
  end


  def update_client node
    @client.update node.ip_address
  end


  def start node
    @backend.start node, @client.repository_directory( node.ip_address ), Lucie::Log
  end


  ##############################################################################
  private
  ##############################################################################


  def repositories_for nodes
    nodes.collect do | each |
      begin
        @client.repository_name each.ip_address
      rescue
        raise "Configuration repository not found on #{ each.name }."
      end
    end.uniq
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
