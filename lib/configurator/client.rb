require "lucie/logger/null"
require "scm"


class Configurator
  class Client
    attr_writer :ssh


    COMMAND_DIRECTORY = "/var/lib/lucie/bin"
    REPOSITORY_BASE_DIRECTORY = "/var/lib/lucie/config"


    def self.guess_scm node, options = {}
      ssh = SSH.new( options, options[ :messenger ] )
      return "DUMMY_SCM" if options[ :dry_run ]
      repository = ssh.sh( node.ip_address, "ls -1 #{ REPOSITORY_BASE_DIRECTORY }" ).split( "\n" ).first
      ssh.sh( node.ip_address, "ls -1 -d #{ File.join( REPOSITORY_BASE_DIRECTORY, repository, '.*' ) }" ).split( "\n" ).each do | each |
        case File.basename( each )
        when ".hg"
          return "Mercurial"
        when ".svn"
          return "Subversion"
        when ".git"
          return "Git"
        end
      end
      raise "Cannot determine SCM used on #{ node.name }:#{ repository }"
    end


    def initialize scm = nil, options = {}
      @options = options
      @ssh = SSH.new( @options, @options[ :messenger ] )
      @scm = Scm.from( scm, @options ) if scm
    end


    def setup client_ip, logger = Lucie::Logger::Null.new
      unless repository_base_directory_exists?( client_ip )
        @ssh.sh client_ip, "mkdir -p #{ REPOSITORY_BASE_DIRECTORY }"
      end
      unless command_directory_exists?( client_ip )
        @ssh.sh client_ip, "mkdir -p #{ COMMAND_DIRECTORY }"
      end
    end


    def install server_ip, client_ip, url, logger = Lucie::Logger::Null.new
      @url = url
      @ssh.cp client_ip, "#{ Lucie::ROOT }/script/get_confidential_data", COMMAND_DIRECTORY
      @ssh.sh client_ip, "sed -i s/USER/#{ ENV[ 'USER' ] }/ #{ File.join( COMMAND_DIRECTORY, 'get_confidential_data' ) }"
      @ssh.sh client_ip, "sed -i s/SERVER/#{ server_ip }/ #{ File.join( COMMAND_DIRECTORY, 'get_confidential_data' ) }"
      @ssh.sh client_ip, "chmod +x #{ File.join( COMMAND_DIRECTORY, 'get_confidential_data' ) }"
      @ssh.sh_a client_ip, @scm.install_command( File.join( REPOSITORY_BASE_DIRECTORY, Configurator.repository_name_from( url ) ), server_ip, url )
    end


    def update ip
      @scm.update_commands_for( repository_directory( ip ) ).each do | each |
        @ssh.sh_a ip, each
      end
    end


    def start ip, logger = Lucie::Logger::Null.new
      @ssh.sh_a ip, "cd #{ scripts_directory( ip ) } && eval \`#{ ldb_command( ip ) } env\` && make", logger
    end


    def repository_directory ip
      File.join REPOSITORY_BASE_DIRECTORY, repository_name( ip )
    end


    def repository_name ip
      if @options[ :dry_run ]
        "REPOSITORY_NAME"
        # Configurator.repository_name_from( @url )
      else
        @ssh.sh( ip, "ls -1 #{ REPOSITORY_BASE_DIRECTORY }" ).split( "\n" ).first
      end
    end


    ############################################################################
    private
    ############################################################################


    def ldb_command ip
      File.join REPOSITORY_BASE_DIRECTORY, repository_name( ip ), "bin", "ldb"
    end


    def scripts_directory ip
      File.join REPOSITORY_BASE_DIRECTORY, repository_name( ip ), "scripts"
    end


    def command_directory_exists? ip
      begin
        @ssh.sh ip, "test -d #{ COMMAND_DIRECTORY }"
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
