require "command/app"
require "node"
require "nodes"
require "secret-server"
require "highline"


module Command
  module NodeInstall
    class App < Command::App
      def initialize argv = ARGV, messenger = nil
        super argv, messenger
      end


      def main node_name
        update_sudo_timestamp
        start_main_logger
        check_prerequisites
        create_node node_name
        start_secret_server
        setup_ldb
        create_installer
        start_html_logger
        start_super_reboot
        setup_ssh
        setup_first_stage
        install_parallel
      end


      ##########################################################################
      private
      ##########################################################################


      def start_secret_server
        if @options.secret
          password = HighLine.new.ask( "Please enter password to decrypt #{ @options.secret }:" ) do | q |
            q.echo = "*"
          end
          IO.read @options.secret
          secret_server = SecretServer.new( @options.secret, password, debug_options )
          @secret_server = Thread.start do
            secret_server.start
          end
        end
      end


      def start_installer_for node, logger
        local_clone_directory = @ldb ? @ldb.local_clone_directory( @options.ldb_repository ) : nil
        @installer.start node, @options.linux_image, @options.storage_conf, local_clone_directory, logger, @html_logger, debug_options, @messenger
      end


      def create_node node_name
        node = Node.new( node_name, node_options )
        Nodes.add node, debug_options, @messenger
      end


      def node_options
        { 
          :netmask_address => @options.netmask,
          :mac_address => @options.mac,
          :eth1 => @options.eth1,
          :eth2 => @options.eth2,
          :eth3 => @options.eth3,
          :eth4 => @options.eth4
        }
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
