# TODO: 未テスト → サポート外

require 'lucie/setup-harddisks/filesystem'

module Lucie
  module SetupHarddisks
    class SwapFile < Filesystem
      MBYTE = 1024 * 1024

      def initialize()
        @fs_type = "swap"
        @format_program = "mkswap"
        @mount_program = "swapon"
        @fsck_enabled = false
        @format_options = []
        @mount_options = []
        @fstab_options = ["sw"]
        super
      end
      
      public
      def format(file, size)    # size in MB
        make_swap_file(file, size)
        format_command = build_format_command(file)
        result = system(format_command)
        if !result
          raise( StandardError,
                 "Some error occurs while running #{format_command}" )
        end
      end
      
      private
      def make_swap_file(file, size)
        File.open(file, "w") do |f|
          f.truncate(size * MBYTE)
        end
      end

      private
      def check_format_options(op)
        # TODO: 堅牢性のために実装しても良い
        true
      end

      private
      def check_mount_options(op)
        # TODO: 堅牢性のために実装しても良い
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
