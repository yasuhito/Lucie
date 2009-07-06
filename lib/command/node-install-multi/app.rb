require "command/app"
require "configuration"
require "environment"
require "installer"
require "installers"
require "ldb"
require "lucie/logger/html"
require "lucie/utils"
require "mandatory_option_error"
require "node"
require "nodes"


module Command
  module NodeInstallMulti
    class App < Command::App
      include Lucie::Utils


      def initialize argv = ARGV, messenger = nil
        super argv, messenger
      end


      def main node_argv
        parse node_argv
        update_sudo_timestamp
        start_main_logger
        check_prerequisites
        create_nodes
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
        @installer.start node, @node_options[ node.name ].linux_image, @node_options[ node.name ].storage_conf, local_clone_directory, logger, @html_logger, debug_options, @messenger
      end


      def create_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
          Nodes.add node, debug_options, @messenger
        end
      end


      def node_options name
        {
          :netmask_address => @options.netmask,
          :mac_address => @node_options[ name ].mac,
          :eth1 => @node_options[ name ].eth1,
          :eth2 => @node_options[ name ].eth2,
          :eth3 => @node_options[ name ].eth3,
          :eth4 => @node_options[ name ].eth4
        }
      end


      def parse node_argv
        @node_options = {}
        node_argv.each do | name, argv |
          @node_options[ name ] = Command::NodeInstall::Options.new.parse( argv )
          @node_options[ name ].storage_conf ||= @options.storage_conf
          @node_options[ name ].linux_image ||= @options.linux_image
          @node_options[ name ].check_mandatory_options
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
