require "lucie/utils"


module Service
  #
  # Nfs daemon configurator & controller
  #
  class Nfs < Common
    #
    # Nfs configuration file
    #
    class ConfigFile
      def initialize nodes, installer_directory
        @nodes = nodes
        @installer_directory = installer_directory
      end


      def to_s
        lines = @nodes.collect do | each |
          exports_entry_for each
        end
        lines.join "\n"
      end


      ##########################################################################
      private
      ##########################################################################


      def exports_entry_for node
        "#{ @installer_directory } #{ node.ip_address }(async,ro,no_root_squash,no_subtree_check)"
      end
    end


    include Lucie::Utils


    config "/etc/exports"
    prerequisite "nfs-kernel-server"


    def setup nodes, installer_directory
      return if nodes.empty?
      backup
      write_config nodes, installer_directory
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config nodes, installer_directory
      write_file config_path, ConfigFile.new( nodes, installer_directory ).to_s, @debug_options.merge( :sudo => true )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
