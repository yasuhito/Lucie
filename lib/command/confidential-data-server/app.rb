require "command/app"
require "confidential-data-server"


module Command
  module ConfidentialDataServer
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        super argv, debug_options
        @global_options.check_mandatory_options
      end


      def main
        server = ::ConfidentialDataServer.new( @global_options.encrypted_file, password, @debug_options )
        custom_port = @global_options.port
        server.start *[ custom_port ? custom_port.to_i : nil ]
      end


      ##########################################################################
      private
      ##########################################################################


      def password
        pw = ENV[ "LUCIE_PASSWORD" ] || @global_options.password
        raise "password is missing" unless pw
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
