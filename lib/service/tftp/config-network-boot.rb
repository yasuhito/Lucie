require "configuration"
require "lucie"
require "service/tftp/config-file"


module Service
  class Tftp < Common
    #
    # A configuration file generator for network booting with TFTP.
    #
    class ConfigNetworkBoot < ConfigFile
      def initialize node, nfsroot, debug_options
        @node = node
        @nfsroot = nfsroot
        @root = Configuration.tftp_root
        @debug_options = debug_options
      end


      ##########################################################################
      private
      ##########################################################################


      #
      # NOTE: The `boot=live' option is passed to live-initramfs. See
      #       Debian live manual (http://live.debian.net/manual/) for
      #       details.
      #
      def content
        return <<-EOF
default lucie

label lucie
kernel #{ INSTALLER_KERNEL }
append initrd=#{ initrd } ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ @nfsroot } boot=live hostname=#{ @node.name }
EOF
      end


      def initrd
        check_initrd
        File.basename initrd_list.first
      end


      def check_initrd
        size = initrd_list.size
        raise Lucie::InternalError, "No initrd.img-* found on #{ @root }" if size == 0
        raise Lucie::InternalError, "Multiple initrd.img-* found on #{ @root }" if size > 1
      end


      def initrd_list
        dry_run ? [ "initrd.img-dryrun" ] : Dir.glob( File.join( @root, "initrd.img-*" ) )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
