module Command
  module NodeInstallMulti
    class Parser
      def initialize argv
        @argv = argv
      end


      def parse
        node_options = {}
        argv_node_options.each do | each |
          name, *values = each.split( /\s+/ )
          node_options[ name ] = values
        end
        node_options
      end


      ##########################################################################
      private
      ##########################################################################


      def argv_node_options
        @argv.select do | each |
          not global_option?( each )
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
