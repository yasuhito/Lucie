require "service/tftp/config-file"


module Service
  class Tftp < Common
    class ConfigNetworkBoot < ConfigFile
      def initialize node, installer, debug_options
        @mac = node.mac_address
        @node = node
        @installer = installer
        @debug_options = debug_options
      end


      ##########################################################################
      private
      ##########################################################################


      # [TODO] Add comments for 'append' option.
      # [???] idle=poll pci=noacpi nobiospnp noapic nolapic
      def content
        return <<-EOF
default lucie

label lucie
kernel #{ INSTALLER_KERNEL }
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ Nfsroot.path( @installer ) },v2,rsize=32768,wsize=32768 hostname=#{ @node.name } irqpoll
EOF
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
