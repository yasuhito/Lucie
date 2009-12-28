module Service
  class Tftp < Common
    class ConfigFile
      include Lucie::Utils


      INSTALLER_KERNEL = "lucie"


      def self.all
        Dir.glob Tftp.pxe_directory + "/*"
      end


      def self.tftpd_default
        return <<-EOF
RUN_DAEMON="yes"
OPTIONS="-v -l -s #{ Configuration.tftp_root }"
EOF
      end


      def initialize mac
        @mac = mac
      end


      def create
        write_file path, content, @debug_options.merge( :sudo => true )
      end


      def path
        File.join Tftp.pxe_directory, pxe_mac_file
      end


      ##########################################################################
      private
      ##########################################################################


      #
      # PXELINUX will search for the config file using the hardware type
      # (using its ARP type code) and address, all in lower case
      # hexadecimal with dash separators; for example, for an Ethernet
      # (ARP type 1) with address 88:99:AA:BB:CC:DD it would search for
      # the filename 01-88-99-aa-bb-cc-dd.
      #
      # See also /usr/share/doc/syslinux/pxelinux.txt.gz included in
      # syslinux debian package.
      #
      def pxe_mac_file
        "01-#{ @mac.gsub( ':', '-' ).downcase }"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
