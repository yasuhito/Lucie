require "service/tftp/config-file"


module Service
  class Tftp < Common
    class ConfigLocalBoot < ConfigFile
      CONTENT = <<-EOF
default local

label local
localboot 0
EOF


      def initialize mac, debug_options
        @mac = mac
        @debug_options = debug_options
      end


      ##########################################################################
      private
      ##########################################################################


      def content
        CONTENT
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

