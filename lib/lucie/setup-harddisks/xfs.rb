#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'lucie/setup-harddisks/filesystem'

module Lucie
  module SetupHarddisks
    class Xfs < Filesystem
      MAX_LABEL_LENGTH = 12

      def initialize()
        @fs_type = "xfs"
        @format_program = "mkfs.xfs"
        @mount_program = "mount -t xfs"
        @fsck_enabled = false   # true?
        @format_options = ["-f"]
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
        if label.length > MAX_LABEL_LENGTH
          raise StandardError, "Label ('#{label}') length can be at most #{MAX_LABEL_LENGTH} characters."
        else
          return " -L #{label}"
        end
      end
    end
  end
end
### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End: