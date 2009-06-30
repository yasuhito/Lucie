require "lucie/io"


module Command
  class App
    include Lucie::IO


    attr_reader :options


    def initialize argv, messenger
      @argv = argv
      @options = parse_argv
      @dry_run = @options.dry_run
      @verbose = @options.verbose
      @messenger = messenger
      usage_and_exit if @options.help
      @options.check_mandatory_options
    end


    def usage_and_exit
      print @options.usage
      exit 0
    end


    ############################################################################
    private
    ############################################################################


    def debug_options
      { :verbose => @verbose, :dry_run => @dry_run }
    end


    def parse_argv
      options_class.new.parse @argv
    end


    def options_class
      instance_eval do | obj |
        eval ( obj.class.to_s.split( "::" )[ 0..-2 ] + [ "Options" ] ).join( "::" )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
