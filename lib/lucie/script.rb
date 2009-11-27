module Lucie
  module Script
    def self.handle_exception app, e
      $stderr.puts "ERROR: " + e.message
      if app and app.options.verbose
        e.backtrace.each do | each |
          $stderr.puts each
        end
      end
      exit -1
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
