require "command/app"
require "secret-server"


module Command
  module SecretServer
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        super argv, debug_options
      end


      def main
        ::SecretServer.new( @options.secret, password, debug_options ).start
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
