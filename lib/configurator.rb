require "configurator/client"
require "configurator/server"
require "lucie/logger/null"


class Configurator
  def self.repository_name_from url
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
    @server.setup
    @server.clone url
    @server.clone_clone url, lucie_ip
  end


  def clone_to_client url, node, lucie_ip, logger = Lucie::Logger::Null.new
    @client.setup node.ip_address
    @client.install lucie_ip, node.ip_address, url
  end


  def update_server url
    @server.update self.class.repository_name_from( url )
  end


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      @server.update each
    end
  end


  def update_client node
    @client.update node.ip_address
  end


  def start node, logger = Lucie::Logger::Null.new
    @client.start node.ip_address
  end


  ##############################################################################
  private
  ##############################################################################


  def repositories_for nodes
    list = nodes.collect do | each |
      begin
        repository_name each.ip_address
      rescue
        raise "Configuration repository for #{ each.name } not found on Lucie server."
      end
    end
    list.uniq
  end


  def repository_name ip_address
    return "REPOSITORY_NAME" if @options[ :dry_run ]
    @client.repository_name ip_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
