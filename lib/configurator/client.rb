require "lucie/logger/null"
require "scm"


class Configurator
  class Client
    attr_writer :ssh


    REPOSITORY_BASE_DIRECTORY = "/var/lib/lucie/config"


    def self.guess_scm node, debug_options = {}
      return "DUMMY_SCM" if debug_options[ :dry_run ]
      ssh = SSH.new( debug_options, debug_options[ :messenger ] )
      repository_dir = File.join( REPOSITORY_BASE_DIRECTORY, ssh.sh( node.ip_address, "ls -1 #{ REPOSITORY_BASE_DIRECTORY }" ).chomp )
      ssh.sh( node.ip_address, "ls -1 -d #{ File.join( repository_dir, '.*' ) }" ).split( "\n" ).each do | each |
        case File.basename( each )
        when ".hg"
          return "Mercurial"
        when ".svn"
          return "Subversion"
        when ".git"
          return "Git"
        end
      end
      raise "Cannot determine SCM used on #{ node.name }:#{ repository_dir }"
    end


    def initialize scm = nil, debug_options = {}
      @debug_options = debug_options
      @ssh = SSH.new( @debug_options, @debug_options[ :messenger ] )
      @scm = Scm.from( scm, @debug_options ) if scm
    end


    def install server_ip, client_ip, url, logger = Lucie::Logger::Null.new
      setup client_ip, logger
      install_get_confidential_data client_ip, server_ip
      install_repository client_ip, server_ip, url
    end


    def update client_ip, server_ip, repository
      update_commands( client_ip, server_ip, REPOSITORY_BASE_DIRECTORY ).each do | each |
        @ssh.sh_a client_ip, each
      end
    end


    def start ip, logger = Lucie::Logger::Null.new    
      @ssh.sh_a ip, "cd #{ scripts_directory( ip ) } && eval \\`#{ ldb_command( ip ) } env\\` && make", logger
    end


    def repository_name client_ip
      return "REPOSITORY_NAME" if @debug_options[ :dry_run ]
      @ssh.sh( client_ip, "ls -1 #{ REPOSITORY_BASE_DIRECTORY }" ).chomp
    end


    ############################################################################
    private
    ############################################################################


    # Paths ####################################################################


    def repository_directory client_ip
      File.join REPOSITORY_BASE_DIRECTORY, repository_name( client_ip )
    end


    def repository_directory_from url
      File.join REPOSITORY_BASE_DIRECTORY, Configurator.repository_name_from( url )
    end


    def scripts_directory ip
      File.join repository_directory( ip ), "scripts"
    end


    def bin_directory
      "/var/lib/lucie/bin"
    end


    def ldb_command ip
      File.join repository_directory( ip ), "bin", "ldb"
    end


    def get_confidential_data_command
      File.join bin_directory, "get_confidential_data"
    end


    # Client-side operations ###################################################


    def setup client_ip, logger
      unless repository_base_directory_exists?( client_ip )
        create_repository_base_directory client_ip
      end
      unless bin_directory_exists?( client_ip )
        create_bin_directory client_ip
      end
    end


    def create_repository_base_directory client_ip
      @ssh.sh client_ip, "mkdir -p #{ REPOSITORY_BASE_DIRECTORY }"
    end


    def create_bin_directory client_ip
      @ssh.sh client_ip, "mkdir -p #{ bin_directory }"
    end


    def install_get_confidential_data client_ip, server_ip
      target = get_confidential_data_command
      @ssh.cp client_ip, "#{ Lucie::ROOT }/script/get_confidential_data", target
      @ssh.sh client_ip, "sed -i s/USER/#{ ENV[ 'USER' ] }/ #{ target }"
      @ssh.sh client_ip, "sed -i s/SERVER/#{ server_ip }/ #{ target }"
      @ssh.sh client_ip, "chmod +x #{ target }"
    end


    def install_repository client_ip, server_ip, url
      @ssh.sh_a client_ip, @scm.install_command( REPOSITORY_BASE_DIRECTORY, server_ip, url )
    end


    def update_commands client_ip, server_ip, repository
      @scm.update_commands_for repository_directory( client_ip ), server_ip, repository
    end


    def bin_directory_exists? ip
      begin
        @ssh.sh ip, "test -d #{ bin_directory }"
        true
      rescue
        false
      end
    end


    def repository_base_directory_exists? ip
      begin
        @ssh.sh ip, "test -d #{ REPOSITORY_BASE_DIRECTORY }"
        true
      rescue
        false
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
