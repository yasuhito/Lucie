require "service/tftp/config-file"


module Service
  class Tftp < Common
    #
    # A configuration file generator for local booting with TFTP.
    #
    class ConfigLocalBoot < ConfigFile
      def self.content
        return <<-EOF
default local

label local
localboot 0
EOF
      end


      def initialize node, debug_options
        @node = node
        @debug_options = debug_options
      end


      ##########################################################################
      private
      ##########################################################################


      def content
        self.class.content
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

