module Configurator
  class Client
    attr_writer :ssh


    def initialize scm = nil, options = {}
      @options = options
      @ssh = SSH.new( @options, @options[ :messenger ] )
      @scm = Scm.from( scm, @options ) if scm
    end


    def setup ip
      unless checkout_base_directory_exists?( ip )
        @ssh.sh ip, "mkdir -p #{ checkout_base_directory }"
      end
    end


    def install server_ip, client_ip, url
      @ssh.sh client_ip, @scm.install_command( checkout_base_directory, server_ip, url )
    end


    def update ip
      @scm.update_commands.each do | each |
        @ssh.sh ip, "cd #{ checkout_directory( ip ) } && #{ each }"
      end
    end


    def start ip
      @ssh.sh ip, "cd #{ scripts_directory( ip ) } && eval `ssh -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ ip } #{ ldb_command( ip ) } env` && make"
    end


    ############################################################################
    private
    ############################################################################


    def ldb_command ip
      File.join checkout_base_directory, checkout_name( ip ), "bin", "ldb"
    end


    def scripts_directory ip
      File.join checkout_base_directory, checkout_name( ip ), "scripts"
    end


    def checkout_directory ip
      File.join checkout_base_directory, checkout_name( ip )
    end


    def checkout_name ip
      if @options[ :dry_run ]
        "DUMMY_LDB_DIR"
      else
        @ssh.sh( ip, "ls -1 #{ checkout_base_directory }" ).split( "\n" ).first
      end
    end



    def checkout_base_directory_exists? ip
      begin
        @ssh.sh ip, "test -d #{ checkout_base_directory }"
        true
      rescue
        false
      end
    end


    def checkout_base_directory
      "/var/lib/lucie/config"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
