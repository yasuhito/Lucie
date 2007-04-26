#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

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
        # TODO: Œ˜˜S«‚Ì‚½‚ß‚ÉŽÀ‘•‚µ‚Ä‚à—Ç‚¢
        true
      end

      private
      def check_mount_options(op)
        # TODO: Œ˜˜S«‚Ì‚½‚ß‚ÉŽÀ‘•‚µ‚Ä‚à—Ç‚¢
        true
      end

    end
  end
end
### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End: