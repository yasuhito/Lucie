require "lucie/debug"
require "lucie/utils"


module Service
  #
  # A controller class for inetd.
  #
  class Inetd
    include Lucie::Debug
    include Lucie::Utils


    def initialize debug_options
      @debug_options = debug_options
    end


    def disable service
      return if disabled?( service )
      update_inetd_disable service
      maybe_restart
    end


    ############################################################################
    private
    ############################################################################


    def disabled? service
      not ( /^#{ service }\s+/=~ inetd_conf )
    end


    def maybe_restart
      inetd_pid = "/var/run/inetd.pid"
      if dry_run || FileTest.exists?( inetd_pid )
        sudo_run "kill -HUP `cat #{ inetd_pid }`", @debug_options
      end
    end


    def update_inetd_disable service
      sudo_run "/usr/sbin/update-inetd --disable #{ service }", @debug_options
    end


    def inetd_conf
      IO.read( @debug_options[ :inetd_conf ] || "/etc/inetd.conf" )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
