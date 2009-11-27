require "lucie/io"
require "lucie/utils"


class Service
  class Approx < Service
    include Lucie::IO
    include Lucie::Utils


    config "/etc/approx/approx.conf"
    prerequisite "approx"


    def setup debian_repository
      info "Setting up approx ..."
      write_config debian_repository
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config debian_repository
      write_file @@config, <<-CONFIG, @debug_options.merge( :sudo => true ), @debug_options[ :messenger ]
debian          #{ debian_repository }
security        http://security.debian.org/debian-security
volatile        http://volatile.debian.org/debian-volatile
CONFIG
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
