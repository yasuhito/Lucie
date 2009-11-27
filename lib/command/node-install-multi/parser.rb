require "command/node-install/options"


module Command
  module NodeInstallMulti
    class Parser
      def initialize argv, global_options
        @argv = argv
        @global_options = global_options
      end


      def parse
        node_options = {}
        argv_node_options.each do | name, *values |
          node_options[ name ] = node_option( values )
        end
        node_options
      end


      ##########################################################################
      private
      ##########################################################################


      def node_option values
        option = Command::NodeInstall::Options.new.parse( values )
        merge_with_global_options option
        option.check_mandatory_options
        option
      end


      def merge_with_global_options option
        option.suite ||= @global_options.suite
        option.storage_conf ||= @global_options.storage_conf
        option.linux_image ||= @global_options.linux_image
        option.netmask ||= @global_options.netmask
      end


      def argv_node_options
        @argv.select do | each |
          not global_option?( each )
        end.collect do | each |
          each.split /\s+/
        end
      end


      def global_option? option
        ( /\A\-/=~ option ) || ( /\A\S+\Z/=~ option )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
