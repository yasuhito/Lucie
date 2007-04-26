#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'lucie/setup-harddisks/filesystem'

module Lucie
  module SetupHarddisks
    class Ext2 < Filesystem
      def initialize()
        @fs_type = "ext2"
        @format_program = "mke2fs"
        @mount_program = "mount -t ext2"
        @fsck_enabled = true
        @format_options = []
        @mount_options = []
        @fstab_options = ["defaults"]
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
      
      private
      def gen_label_option(label)
        return " -L #{label}"
      end
    end
  end
end
### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End: