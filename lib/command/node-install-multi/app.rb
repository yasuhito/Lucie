require "command/app"
require "configurator"
require "node"
require "nodes"


module Command
  module NodeInstallMulti
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main node_argv
        begin
          parse node_argv
          generate_ssh_keypair
          update_sudo_timestamp
          start_main_logger
          check_prerequisites
          create_nodes
          start_secret_server
          setup_ldb
          create_installer
          start_html_logger
          start_super_reboot
          setup_ssh
          setup_first_stage
          install_parallel
        rescue
          @tp.killall
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              @html_logger.update_status( each, "failed" ) if @html_logger
            end
          end
        end
      end



      ##########################################################################
      private
      ##########################################################################


      def start_installer_for node, logger
        server_clone_directory = @options.ldb_repository ? Configurator::Server.clone_directory( @options.ldb_repository ) : nil
        @installer.start node, @node_options[ node.name ].suite || "stable", @node_options[ node.name ].linux_image, @node_options[ node.name ].storage_conf, server_clone_directory, logger, @html_logger, debug_options, @messenger
      end


      def create_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
          Nodes.add node, debug_options, @messenger
        end
      end


      def node_options name
        { :netmask_address => @node_options[ name ].netmask, :mac_address => @node_options[ name ].mac, :ip_address => ip_address( name ) }
      end


      def ip_address name
        node = Nodes.find( name )
        return node.ip_address if node
        return @node_options[ name ].ip_address if @node_options[ name ].ip_address
        nil
      end


      def parse node_argv
        @node_options = {}
        node_argv.each do | name, argv |
          @node_options[ name ] = Command::NodeInstall::Options.new.parse( argv )
          @node_options[ name ].storage_conf ||= @options.storage_conf
          @node_options[ name ].linux_image ||= @options.linux_image
          @node_options[ name ].netmask ||= @options.netmask
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
