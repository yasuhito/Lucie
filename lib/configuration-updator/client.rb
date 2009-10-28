require "ssh"
require "lucie/server"


class ConfigurationUpdator
  class Client
    def initialize debug_options = {}
      @debug_options = debug_options
      @ssh = SSH.new( @debug_options )
      @client = Configurator::Client.new( nil, @debug_options )
    end


    def update node, server_repository
      begin
        update_commands( node, server_repository ).each do | each |
          @ssh.sh_a node.ip_address, each
        end
      rescue => e
        raise "Failed to update #{ node.name }: #{ e.message }"
      end
    end


    def repository_name_of node
      return @debug_options[ :repository_name ] if @debug_options[ :repository_name ]
      follow_repository_symlink_of node
    end


    def start node, logger
      @client.start node.ip_address, logger
    end


    ############################################################################
    private
    ############################################################################


    def update_commands node, server_repository
      scm = Scm.new( @debug_options ).from( server_repository )
      scm.test_installed_on node
      server_ip = Lucie::Server.ip_address_for( [ node ], @debug_options )
      scm.update_commands_for( Configurator::Client::REPOSITORY, server_ip, server_repository )
    end


    def follow_repository_symlink_of node
      begin
        /ldb \-> (\S+)$/=~ @ssh.sh( node.ip_address, "ls -l #{ Configurator::Client::BASE_DIRECTORY }" ).chomp
        name = File.basename( $1 ) if $1
        raise if name.empty?
      rescue
        raise "Configuration repository not found on #{ node.name }:#{ Configurator::Client::REPOSITORY_BASE_DIRECTORY }"
      end
      name
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
