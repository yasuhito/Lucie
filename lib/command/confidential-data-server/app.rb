require "command/app"
require "confidential-data-server"


module Command
  module ConfidentialDataServer
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        super argv, debug_options
      end


      def main
        ::ConfidentialDataServer.new( @global_options.encrypted_file, password, @debug_options.merge( :port => @global_options.port ) ).start
      end


      ##########################################################################
      private
      ##########################################################################


      def password
        pw = ENV[ "LUCIE_PASSWORD" ]
        raise "Environment variable 'LUCIE_PASSWORD' is not set!" unless pw
        pw
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
