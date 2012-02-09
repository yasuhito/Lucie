require "lucie/server"
require "lucie/utils"


module Service
  #
  # Dhcp daemon controller & configurator
  #
  class Dhcp < Common
    #
    # Dhcp configuration file
    #
    class ConfigFile
      #
      # subnet stanza in dhcpd.conf
      #
      class SubnetEntry
        def initialize nodes, subnet, netmask, debug_options
          @nodes = nodes
          @subnet = subnet
          @netmask = netmask
          @debug_options = debug_options
        end


        def to_s
          <<-EOF
subnet #{ @subnet } netmask #{ @netmask } {
  option broadcast-address #{ @nodes.first.broadcast_address };
  deny unknown-clients;

  next-server #{ Lucie::Server.ip_address_for( @nodes, @debug_options ) };
  filename "pxelinux.0";

#{ host_entries.join "\n" }
}
EOF
        end


        ########################################################################
        private
        ########################################################################


        def host_entries
          @nodes.collect do | each |
            HostEntry.new( each ).to_s
          end
        end
      end


      #
      # host stanza in dhcpd.conf
      #
      class HostEntry
        def initialize node
          @node = node
        end


        def to_s
        <<-EOF
  host #{ @node.name } {
    hardware ethernet #{ @node.mac_address };
    fixed-address #{ @node.ip_address };
  }
EOF
        end
      end


      def initialize nodes, debug_options
        @nodes = nodes.sort_by { | each | each.name }
        @debug_options = debug_options
      end


      def to_s
        <<-EOF
option domain-name "#{ Lucie::Server.domain }";

#{ subnet_entries }
EOF
      end


      ##########################################################################
      private
      ##########################################################################


      def subnet_entries
        subnets.inject( "" ) do | result, each |
          result + subnet_entry_for( *each )
        end
      end


      def subnet_entry_for netinfo, nodes
        subnet, netmask = netinfo
        SubnetEntry.new( nodes, subnet, netmask, @debug_options ).to_s
      end


      #
      # returns all the subnet and netmask addresses used by nodes.
      #
      # return value:
      #   a Hash of [ network_address, netmask_address ] => [ node1, node2, ... ]
      #
      def subnets
        result = Hash.new( [] )
        @nodes.each do | each |
          result[ each.net_info ] += [ each ]
        end
        result
      end
    end


    include Lucie::Utils


    config "/etc/dhcp/dhcpd.conf"
    prerequisite "dhcp3-server"


    def setup nodes
      return if nodes.empty?
      backup
      write_config nodes
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config nodes
      write_file config_path, ConfigFile.new( nodes, @debug_options ).to_s, @debug_options.merge( :sudo => true )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
