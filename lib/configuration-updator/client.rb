require "ssh"
require "lucie/server"


class ConfigurationUpdator
  class Client
    REPOSITORY_BASE_DIRECTORY = "/var/lib/lucie/config"


    def initialize debug_options = {}
      @debug_options = debug_options
      @ssh = SSH.new( @debug_options, @debug_options[ :messenger ] )
    end


    def update node, server_repository
      update_commands( node, server_repository ).each do | each |
        @ssh.sh_a node.ip_address, each
      end
    end


    def repository_name_for node
      return @debug_options[ :repository_name ] if dummy_repository?
      ssh_repository_name node
    end


    def start node, logger
      @ssh.sh_a node.ip_address, "cd #{ scripts_directory( node ) } && eval \\`#{ ldb_command( node ) } env\\` && make", logger
    end


    ############################################################################
    private
    ############################################################################


    # Paths ####################################################################


    def repository_directory node
      Configurator::Client::REPOSITORY
    end


    def scripts_directory node
      File.join repository_directory( node ), "scripts"
    end


    def ldb_command node
      File.join repository_directory( node ), "bin", "ldb"
    end


    # Utils ####################################################################


    def update_commands node, server_repository
      scm = Scm.new( @debug_options ).from( server_repository )
      scm.test_installed_on node
      server_ip = Lucie::Server.ip_address_for( [ node ], @debug_options )
      scm.update_commands_for( repository_directory( node ), server_ip, server_repository )
    end


    def ssh_repository_name node
      begin
        /ldb \-> (\S+)$/=~ @ssh.sh( node.ip_address, "ls -l /var/lib/lucie/" ).chomp
        name = File.basename( $1 ) if $1
        raise if name.empty?
      rescue
        raise "Configuration repository not found on #{ node.name }:#{ REPOSITORY_BASE_DIRECTORY }"
      end
      name
    end


    # Debug ####################################################################


    def dummy_repository?
      @debug_options[ :dry_run ] and @debug_options[ :repository_name ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
