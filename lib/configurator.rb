require "configurator/client"
require "configurator/server"


class Configurator
  def self.convert url
    url.gsub( /[\/:@]/, "_" )
  end


  def initialize options
    @options = options
    @client = Client.new( :mercurial, @options )
    @server = Server.new( :mercurial, @options )
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


  def update node, logger = nil
    @server.update @client.repository_name( node.ip_address )
    @client.update node.ip_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
