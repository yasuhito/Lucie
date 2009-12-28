require "configurator/client"
require "configurator/server"
require "lucie/logger/null"
require "lucie/server"


class Configurator
  def self.repository_name_from url
    raise "Repository url not specified" unless url
    url.gsub( /[\/:@]/, "_" )
  end


  def self.guess_scm node, options = {}
    Client.guess_scm node, options
  end


  def initialize scm, options = {}
    @options = options
    @client = Client.new( scm, @options )
    @server = Server.new( scm, @options )
  end


  def clone_to_server url, lucie_ip
    @server.clone url
    @server.clone_clone url, lucie_ip
  end


  def clone_to_client url, node, lucie_ip, logger = Lucie::Logger::Null.new
    @client.install lucie_ip, node.ip_address, url, logger
    @client.update_symlink url, node.ip_address
  end


  def update_server url
    @server.update self.class.repository_name_from( url )
  end


  def update_client node
    @client.update node.ip_address, lucie_server_ip_address_for( [ node ] )
  end


  def start node, logger = Lucie::Logger::Null.new
    @client.start node.ip_address, logger
  end


  def custom_dpkg= dpkg
    @server.custom_dpkg = dpkg
  end


  ##############################################################################
  private
  ##############################################################################


  def lucie_server_ip_address_for nodes
    Lucie::Server.ip_address_for nodes, @options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
