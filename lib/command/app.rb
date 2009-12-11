require "lucie/debug"


module Command
  class App
    include Lucie::Debug


    def self.options_class_name
      instance_eval do | obj |
        obj.name.gsub /App\Z/, "Options"
      end
    end


    def initialize argv, debug_options
      @argv = argv
      @global_options = parse_argv
      @debug_options = global_debug_options.merge( debug_options )
      usage_and_exit if @global_options.help
    end


    def usage_and_exit
      stdout.print @global_options.usage
      exit 0
    end


    ############################################################################
    private
    ############################################################################


    def global_debug_options
      { :verbose => @global_options.verbose,
        :dry_run => @global_options.dry_run }
    end


    def parse_argv
      options_class.new.parse @argv
    end


    def options_class
      eval self.class.options_class_name
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
