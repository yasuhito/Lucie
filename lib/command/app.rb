require "lucie/debug"
require "lucie/server"
require "thread_pool"


module Command
  class App
    include Lucie::Debug


    def initialize argv, debug_options
      @argv = argv
      @global_options = parse_argv
      @debug_options = { :verbose => @global_options.verbose, :dry_run => @global_options.dry_run }.merge( debug_options )
      @tp = ThreadPool.new
      usage_and_exit if @global_options.help
      @global_options.check_mandatory_options
    end


    def usage_and_exit
      print @global_options.usage
      exit 0
    end


    ############################################################################
    private
    ############################################################################


    def parse_argv
      options_class.new.parse @argv
    end


    def options_class
      instance_eval do | obj |
        eval ( obj.class.to_s.split( "::" )[ 0..-2 ] + [ "Options" ] ).join( "::" )
      end
    end


    def lucie_server_ip_address
      if dry_run and @debug_options[ :nic ]
        @debug_options[ :nic ].first.ip_address
      else
        Lucie::Server.ip_address_for Nodes.load_all
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
