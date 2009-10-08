module Lucie
  module Debug
    def debug message
      @logger.debug message if @logger and ( not dry_run )
      stderr.puts message if verbose
    end


    def dry_run
      @debug_options[ :dry_run ]
    end


    def verbose
      @debug_options[ :verbose ]
    end


    def stderr
      @debug_options[ :messenger ] || $stderr
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
