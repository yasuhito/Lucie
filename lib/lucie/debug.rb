module Lucie
  module Debug
    def info message
      @logger.info message if @logger and ( not dry_run )
      stdout.puts message
    end


    def debug message
      @logger.debug message if @logger and ( not dry_run )
      stderr.puts message if verbose
    end


    def error message
      @logger.error message if @logger and ( not dry_run )
      stderr.puts message
    end


    def dry_run
      @debug_options[ :dry_run ]
    end


    def verbose
      @debug_options[ :verbose ]
    end


    def stdout
      messenger || $stdout
    end


    def stderr
      messenger || $stderr
    end


    def messenger
      @debug_options[ :messenger ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
