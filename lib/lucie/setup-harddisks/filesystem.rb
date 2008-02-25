module Lucie
  module SetupHarddisks
    # Abstract class for specific filesystem: such as ext2, ext3, reiserfs, xfs, swap...
    class Filesystem
      attr_reader   :fs_type
      attr_reader   :format_program
      attr_reader   :mount_program
      attr_reader   :fsck_enabled
      attr_accessor :format_options
      attr_accessor :mount_options
      attr_accessor :fstab_options

      public
      def initialize
        if (not format_program_exist?) and $commandline_options.no_test
          raise StandardError, "Cannot find #{@format_program} in the PATH"
        end
      end
      
      public
      def format(slice, label, option = nil)
        format_command = build_format_command(slice, label, option)
        msg = "Formatting #{slice} (#{format_command})"
        if $commandline_options.no_test
          message msg if $commandline_options.verbose
          result = system(format_command)
          if !result
            raise( StandardError,
                   "Some error occurs while running #{format_command}" )
          end
        else
          message msg
        end
      end
      
      public
      def mount(slice, mount_point, option = nil)
        # not used
        mount_command = build_mount_command(slice, mount_point, option)
        msg = "Mounting #{slice} (#{mount_command})"
        if $commandline_options.no_test
          message msg if $commandline_options.verbose
          result = system(mount_command)
          if !result
            raise( StandardError,
                   "Some error occurs while running #{mount_command}" )
          end
        else
          message msg
        end
      end
      
      public
      def mount_with_label(label, mount_point, option = nil)
        # not used
        # label を用いて mount できないファイルシステムがある
        mount_command = build_mount_command_with_label(label, mount_point, option)
        msg = "Mounting #{label} (#{mount_command})"
        if $commandline_options.no_test
          message msg if $commandline_options.verbose
          result = system(mount_command)
          if !result
            raise( StandardError,
                   "Some error occurs while running #{mount_command}" )
          end
        else
          message msg
        end
      end
      
      private
      def build_format_command(slice, label, option = nil)
        (option.nil?)? op = @format_options : op = @format_options + option
        op.uniq!
        if check_format_options(op)
          (op.empty?)? op = "" : op = " " + op.join(" ")
          return @format_program + op + gen_label_option(label) + " #{slice}"
        else
          raise( ArgumentError,
                 "Unknow options for #{@format_program}: " + op.join(" ") )
        end
      end
      
      private
      def gen_label_option(label)
        # Implement this method in subclass if needed.
        return ""
      end

      private
      def build_mount_command(slice, mount_point, option = nil)
        # not used
        (option.nil?)? op = @mount_options : op = @mount_options + option
        op.uniq!
        if check_mount_options(op)
          (op.empty?)? op = "" : op = " " + op.join(" ")
          (mount_point == "none")? mp = "" : mp = mount_point
          return @mount_program + op + " #{slice} #{mp}"
        else
          raise( ArgumentError,
                 "Unknow options for #{@mount_program}: " + op.join(" ") )
        end
      end

      private
      def build_mount_command_with_label(label, mount_point, option = nil)
        # not used
        (option.nil?)? op = @mount_options : op = @mount_options + option
        op.uniq!
        if check_mount_options(op)
          (op.empty?)? op = "" : op = " " + op.join(" ")
          (mount_point == "none")? mp = "" : mp = mount_point
          return @mount_program + op + " -L #{label} #{mp}"
        else
          raise( ArgumentError,
                 "Unknow options for #{@mount_program}: " + op.join(" ") )
        end
      end

      
      private
      def format_program_exist?
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |each|
          return true if FileTest.executable?( File.join(each, @format_program) )
        end
        return false
      end
      
      private
      def message( aString )
        puts aString unless Test::Unit.run?
      end

      # ------------------------- Debug methods.

      public
      def dump_format(slice, label = nil)
        return build_format_command(slice, label)
      end

      public
      def dump_mount(slice, mount_point)
        return build_mount_command(slice, mount_point)
      end

      public
      def dump_mount_with_label(label, mount_point)
        return build_mount_command_with_label(label, mount_point)
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
