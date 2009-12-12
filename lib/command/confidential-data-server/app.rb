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
        cds = new_server
        custom_port = @global_options.port
        custom_port ? cds.start( custom_port.to_i ) : cds.start
      end


      ##########################################################################
      private
      ##########################################################################


      def new_server
        ::ConfidentialDataServer.new( @global_options.encrypted_file, password, @debug_options )
      end


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
