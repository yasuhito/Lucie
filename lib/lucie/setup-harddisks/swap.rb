require 'lucie/setup-harddisks/filesystem'

module Lucie
  module SetupHarddisks
    class Swap < Filesystem
      def initialize
        @fs_type = "swap"
        @format_program = "mkswap"
        @mount_program = "swapon"
        @fsck_enabled = false
        @format_options = []
        @mount_options = []
        @fstab_options = ["sw"]
        super
      end
      
      private
      def check_format_options(op)
        # TODO: ÂŒÂ˜Â˜SÂÂ«Â‚œô¥ÂÂ½Â‚œô²¢œô£ÎÃ€Â‘Â•Â‚ÂµÂ‚œô ¢Ã Â—œô¢¢Â¢
        true
      end

      private
      def check_mount_options(op)
        # TODO: ÂŒÂ˜Â˜SÂÂ«Â‚œô¥ÂÂ½Â‚œô²¢œô£ÎÃ€Â‘Â•Â‚ÂµÂ‚œô ¢Ã Â—œô¢¢Â¢
        true
      end

    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
