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


  def update_server_for nodes
    repositories_for( nodes ).each do | each |
      @server.update each
    end
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
    if @options[ :dry_run ] and @options[ :nic ]
      @options[ :nic ].first.ip_address
    else
      Lucie::Server.ip_address_for nodes
    end
  end


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


  #
  # Returns a basename of the file referenced by ldb symbolic link
  # (/var/lib/lucie/ldb). 
  #
  # Example:
  #   Given that /var/lib/lucie/ldb on 192.168.0.100 refers to
  #   /var/lib/lucie/config/svn+ssh___intri_www.intrigger.jp_home_intri_SVN_L4,
  # 
  #   Then,
  #   Configurator#repository_name( "192.168.0.100" )
  #     #=> "svn+ssh___intri_www.intrigger.jp_home_intri_SVN_L4"
  #
  def repository_name ip_address
    return "REPOSITORY" if @options[ :dry_run ]
    @client.repository_name ip_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
