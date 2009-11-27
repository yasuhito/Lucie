module Lucie
  module Script
    def self.handle_exception exception, verbose
      $stderr.puts "ERROR: " + exception.message
      if verbose
        exception.backtrace.each do | each |
          $stderr.puts each
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
