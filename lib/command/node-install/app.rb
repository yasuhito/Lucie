require "command/app"
require "confidential-data-server"
require "node"
require "nodes"


module Command
  module NodeInstall
    class App < Command::App
      def initialize argv = ARGV, messenger = nil
        super argv, :messenger => messenger
        @global_options.check_mandatory_options
      end


      def main node_name
        generate_ssh_keypair
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


      def start_installer_for node, logger
        local_clone_directory = @ldb ? @ldb.local_clone_directory( @options.ldb_repository ) : nil
        @installer.start node, @options.linux_image, @options.storage_conf, local_clone_directory, logger, @html_logger, debug_options, @messenger
      end


      def create_node node_name
        node = Node.new( node_name, node_options )
        Nodes.add node, debug_options, @messenger
      end


      def node_options
        { :netmask_address => @options.netmask, :mac_address => @options.mac }
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
