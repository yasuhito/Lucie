#
# A class for RAILS_ROOT/nodes/[node_name]/ directory.
#


class Node
  attr_accessor :path
  attr_reader :gateway_address
  attr_reader :install_command
  attr_reader :ip_address
  attr_reader :mac_address
  attr_reader :name
  attr_reader :netmask_address


  def installer_name
    files.each do | each |
      if File.file?( each ) and ( not File.basename( each ).match( mac_address_file_regex )  )
        return File.basename( each, '.DISABLE' )
      end
    end
    nil
  end


  ################################################################################
  # node creation
  ################################################################################


  def self.read dir
    @node_in_the_works = Node.new( File.basename( dir ) )
  end


  def initialize name, network_options = {}
    @name = name
    if @name.nil?
      raise 'name is mandatory.'
    end
    @mac_address = network_options[ :mac_address ]
    @gateway_address = network_options[ :gateway_address ]
    @ip_address = network_options[ :ip_address ]
    @netmask_address = network_options[ :netmask_address ]
    @path = File.join( Configuration.nodes_directory, @name )

    if network_options.empty?
      load_network_option_file
    end
    validate_network_options
  end


  ################################################################################
  # enable/disable
  ################################################################################


  def enable! iname
    if installer_file
      FileUtils.rm installer_file
    end
    FileUtils.touch file( iname )
  end


  def disable!
    if installer_file
      iname = installer_name
      FileUtils.rm installer_file
      FileUtils.touch disable_file( iname )
    end
  end


  def enable?
    if installer_name and ( not File.file?( disable_file( installer_name ) ) )
      return true
    end
    false
  end


  ################################################################################
  # install history
  ################################################################################


  def installs
    the_installs = Dir[ "#{ @path }/install-*/install_status.*" ].collect do | status_file |
      install_directory = File.basename( File.dirname( status_file ) )
      install_label = install_directory[ 8..-1 ]
      Install.new self, install_label
    end
    order_by_label the_installs
  end


  def last_five_installs
    last_installs( 5 )
  end


  def latest_install
    last_installs( 1 )[ 0 ]
  end


  def last_installs n
    installs.reverse[ 0..( n - 1 ) ]
  end


  def last_complete_install_status
    last_complete_install ? last_complete_install.status : 'never_installed'
  end


  def last_complete_install
    installs.reverse.each do | each |
      unless each.incomplete?
        return each
      end
    end
    return nil
  end


  ################################################################################
  # misc
  ################################################################################


  def == another
    return( another.is_a?( Node ) and another.name == self.name )
  end


  ################################################################################
  private
  ################################################################################


  def installer_file
    unless installer_name
      return nil
    end

    if File.file? file( installer_name )
      return file( installer_name )
    end
    if File.file? file( installer_name + '.DISABLE' )
      return file( installer_name + '.DISABLE' )
    end
  end


  def disable_file iname
    file( iname + '.DISABLE' )
  end


  def file fname
    File.join( @path, fname )
  end


  def files
    Dir[ "#{ @path }/*" ]
  end


  def order_by_label installs
    installs.sort_by do | install |
      install.label
    end
  end


  def validate_network_options
    if @mac_address.nil?
      raise "MAC address is mandatory."
    end
    if @gateway_address.nil?
      raise "Gateway address is mandatory."
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
    if invalid_address?( @gateway_address )
      raise "'#{ @gateway_address }' is not a valid gateway address."
    end
    if invalid_address?( @ip_address )
      raise "'#{ @ip_address }' is not a valid IP address."
    end
    if invalid_address?( @netmask_address )
      raise "'#{ @netmask_address }' is not a valid netmask address."
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


  def load_network_option_file
    unless mac_address_file
      raise "MAC address for node '#{ @name }' not defined."
    end
    @mac_address = mac_address_file.gsub( '_', ':' )
    File.open( File.join( @path, mac_address_file ), 'r' ) do | file |
      file.read.each_line do | each |
        variable, value = each.chomp.split( ':' )
        instance_variable_set "@#{ variable }".to_sym, value
      end
    end
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
