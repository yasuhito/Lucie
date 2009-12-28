require "lucie/utils"


module Service
  #
  # A controller class of approx debian package proxy. This class
  # automatically configures and restarts approx server.
  #
  class Approx < Common
    include Lucie::Utils


    PORT = 9999
    DEBIAN_REPOSITORY = "debian"
    SECURITY_REPOSITORY = "security"
    VOLATILE_REPOSITORY = "volatile"


    config "/etc/approx/approx.conf"
    prerequisite "approx"


    #
    # Configure approx to use +debian_repository+ for its upstream
    # package repository.
    #
    # Example:
    #  Service::Approx#setup "http://cdn.debian.or.jp/debian"
    #
    def setup debian_repository
      write_config debian_repository
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config debian_repository
      write_file config_path, <<-EOF, @debug_options.merge( :sudo => true )
#{ DEBIAN_REPOSITORY }          #{ debian_repository }
#{ SECURITY_REPOSITORY }        http://security.debian.org/debian-security
#{ VOLATILE_REPOSITORY }        http://volatile.debian.org/debian-volatile
EOF
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
