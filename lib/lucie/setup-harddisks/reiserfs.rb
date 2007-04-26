#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'lucie/setup-harddisks/filesystem'

module Lucie
  module SetupHarddisks
    class Reiserfs < Filesystem
      def initialize()
        @fs_type = "reiserfs"
        @format_program = "mkfs.reiserfs"
        @mount_program = "mount -t reiserfs"
        @fsck_enabled = false   # true?
        @format_options = ["-q"]
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
        return " -l #{label}"
      end
    end
  end
end
### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End: