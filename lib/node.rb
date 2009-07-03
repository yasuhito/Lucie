require "lucie/shell"
require "lucie/utils"
require "network"
require "status/installer"


class Node
  include Lucie::Utils


  attr_reader :eth1
  attr_reader :eth2
  attr_reader :eth3
  attr_reader :eth4
  attr_reader :install_command
  attr_reader :ip_address
  attr_reader :mac_address
  attr_reader :name
  attr_accessor :netmask_address

  attr_accessor :status


  def self.read name, dir
    return nil unless File.directory?( dir )
    node = Node.new( name, dir )
    node.load_network_options
    node.validate_network_options
    node
  end


  def initialize name, attributes = {}
    @name = name
    @mac_address = attributes[ :mac_address ]
    @eth1 = attributes[ :eth1 ]
    @eth2 = attributes[ :eth2 ]
    @eth3 = attributes[ :eth3 ]
    @eth4 = attributes[ :eth4 ]
    @ip_address = attributes[ :ip_address ]
    @netmask_address = attributes[ :netmask_address ]
  end


  def eth_list
    [ @mac_address, @eth1, @eth2, @eth3, @eth4 ].compact
  end


  ################################################################################
  # misc
  ################################################################################


  def remove! options, messenger
    command = "rm -rf #{ path }"
    ( messenger || $stderr ).puts command if options[ :verbose ]
    Lucie::Shell.new.run( command ) unless options[ :dry_run ]
  end


  def load_network_options
    unless mac_address_file
      raise "MAC address for node '#{ @name }' not defined."
    end
    @mac_address = mac_address_file.gsub( '_', ':' )
    File.open( File.join( @path, mac_address_file ), 'r' ) do | file |
      file.read.each_line do | each |
        next if /^$/=~ each
        variable, value = each.chomp.split( ',' )
        instance_variable_set "@#{ variable }".to_sym, value
      end
    end
  end


  def validate_network_options
    if @mac_address.nil?
      raise "#{ @name }: MAC address is mandatory."
    end
    if @ip_address.nil?
      raise "IP address is mandatory."
    end
    if @netmask_address.nil?
      raise "Netmask address is mandatory."
    end

    if invalid_name?
      raise "'#{ @name }' is not a valid node name."
    end
    if invalid_mac_address?
      raise "'#{ @mac_address }' is not a valid MAC address."
    end
    if invalid_address?( @ip_address )
      raise "'#{ @ip_address }' is not a valid IP address."
    end
    if invalid_address?( @netmask_address )
      raise "'#{ @netmask_address }' is not a valid netmask address."
    end
  end


  def == another
    return( another.is_a?( Node ) and another.name == self.name )
  end


  def net_info
    [ Network.network_address( @ip_address, @netmask_address ), netmask_address ]
  end


  ################################################################################
  private
  ################################################################################


  def write_config options, messenger
    eths = %W( eth1 eth2 eth3 eth4 ).collect do | each |
      ethx_mac = instance_variable_get( "@#{ each }" )
      if ethx_mac
        "#{ each },#{ ethx_mac }"
      else
        nil
      end
    end.compact.join( "\n" )
    eth0_mac = File.join( @path, @mac_address.gsub( ':', '_' ) )
    write_file eth0_mac, <<-EOF, options, messenger
ip_address,#{ ip_address }
netmask_address,#{ netmask_address }
#{ eths }
EOF
  end


  def disable_file iname
    file( iname + '.DISABLE' )
  end


  def file fname
    File.join( @path, fname )
  end


  def installer_file
    files.select do | each |
      File.file?( each ) and ( not File.basename( each ).match( mac_address_file_regex )  )
    end.first
  end


  def files
    Dir[ "#{ @path }/*" ]
  end


  def order_by_label installations
    installations.sort_by do | each |
      each.label
    end
  end


  def invalid_name?
    @name.match /[^-_a-zA-Z0-9]/
  end


  def invalid_mac_address?
    not @mac_address.match( mac_address_regex )
  end


  def invalid_address? address
    not address.match( /\d+\.\d+\.\d+\.\d+/ )
  end


  def mac_address_file
    files.each do | each |
      if File.basename( each ).match mac_address_file_regex
        return File.basename( each )
      end
    end
    nil
  end


  def mac_address_regex
    /\A#{ hex_regex }:#{ hex_regex }:#{ hex_regex }:#{ hex_regex }:#{ hex_regex }:#{ hex_regex }\Z/
  end


  def mac_address_file_regex
    /\A#{ hex_regex }_#{ hex_regex }_#{ hex_regex }_#{ hex_regex }_#{ hex_regex }_#{ hex_regex }\Z/
  end


  def hex_regex
    /[a-fA-F0-9][a-fA-F0-9]/
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End: