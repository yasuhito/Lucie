require "rubygems"

require "lucie/io"
require "lucie/server"
require "lucie/utils"
require "network"
require "network_interfaces"


class Service
  class Dhcp < Service
    include Lucie::IO
    include Lucie::Utils


    config "/etc/dhcp3/dhcpd.conf"
    prerequisite "dhcp3-server"


    def setup nodes, interfaces = NetworkInterfaces
      info "Setting up dhcpd ..."
      return if all_subnets( nodes ) == {}
      generate_config_file nodes, interfaces
      restart
    end


    def disable
      run "sudo rm -f #{ @@config }", @options, @messenger
      run 'sudo /etc/init.d/dhcp3-server stop', @options, @messenger
    end


    ############################################################################
    private
    ############################################################################


    def generate_config_file nodes, interfaces
      backup_config_file
      write_file @@config, dhcpd_conf( nodes, interfaces ), @options.merge( :sudo => true ), @messenger
    end


    def restart
      run "sudo /etc/init.d/dhcp3-server restart", @options, @messenger
    end


    def backup_config_file
      if dhcpd_conf_exists?
        run "sudo mv -f #{ @@config } #{ @@config }.old", @options, @messenger
      end
    end


    def dhcpd_conf_exists?
      @options[ :dry_run ] || FileTest.exists?( @@config )
    end


    # Networking ###############################################################


    def broadcast_address nodes
      node = nodes.first
      Network.broadcast_address node.ip_address, node.netmask_address
    end


    #
    # returns all the subnet and netmask addresses used by nodes.
    #
    # return value:
    #   a Hash of [ network_address, netmask_address ] => [ node1, node2, ... ]
    #
    def all_subnets nodes
      subnets = Hash.new( [] )
      nodes.each do | each |
        subnets[ each.net_info ] = subnets[ each.net_info ].push( each )
      end
      subnets
    end


    # dhcpd.conf snippets ######################################################


    def dhcpd_conf nodes, interfaces
      <<-EOF
option domain-name "#{ Lucie::Server.domain }";

#{ subnet_entries( nodes, interfaces ) }
EOF
    end


    def subnet_entries nodes, interfaces
      entries = ""
      all_subnets( nodes ).each_pair do | netinfo, nodes |
        entries += subnet_entry( netinfo, nodes, interfaces )
      end
      entries
    end


    def subnet_entry netinfo, nodes, interfaces
      subnet, netmask = netinfo
      return <<-EOF
subnet #{ subnet } netmask #{ netmask } {
  option broadcast-address #{ broadcast_address( nodes ) };
  deny unknown-clients;

  next-server #{ Lucie::Server.ip_address_for( nodes, interfaces ) };
  filename "pxelinux.0";

#{ host_entries( nodes ) }
}
EOF
    end


    def host_entries nodes
      entries = ""
      nodes.each do | each |
        entries += <<-EOF
  host #{ each.name } {
    hardware ethernet #{ each.mac_address };
    fixed-address #{ each.ip_address };
  }
EOF
      end
      entries
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
