class Node
  attr_accessor :path
  attr_reader :gateway_address
  attr_reader :install_command
  attr_reader :ip_address
  attr_reader :mac_address
  attr_reader :name
  attr_reader :netmask_address


  def self.read dir
    @node_in_the_works = Node.new( File.basename( dir ) )
  end


  def initialize name, options = {}
    @name = name
    @mac_address = options[ :mac_address ]
    @gateway_address = options[ :gateway_address ]
    @ip_address = options[ :ip_address ]
    @netmask_address = options[ :netmask_address ]
    @path = File.join( Configuration.nodes_directory, @name )

    if options.empty?
      load_network_config
    end

    if @mac_address.nil?
      raise "MAC address for node '#{ @name }' not defined."
    end
    if @ip_address.nil?
      raise "IP address for node '#{ @name }' not defined."
    end
    if @gateway_address.nil?
      raise "Gateway address for node '#{ @name }' not defined."
    end
    if @netmask_address.nil?
      raise "Netmask address for node '#{ @name }' not defined."
    end
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


  def installs
    unless path
      raise "Node #{ name.inspect } has no path"
    end

    the_installs = Dir[ "#{ path }/install-*/install_status.*" ].collect do | status_file |
      install_directory = File.basename( File.dirname( status_file ) )
      install_label = install_directory[ 8..-1 ]
      Install.new self, install_label
    end
    order_by_label the_installs
  end


  def order_by_label installs
    installs.sort_by do | install |
      install.label
    end
  end


  def last_installs n
    result = installs.reverse[ 0..( n - 1 ) ]
  end


  def last_five_installs
    last_installs( 5 )
  end


  def latest_install
    return Install.new( self, :latest )
  end


  def disable
    if installer_name
      FileUtils.rm File.join( @path, installer_name )
    end
  end


  def install_with installer_name
    disable
    FileUtils.touch File.join( @path, installer_name )
  end


  def installer_name
    Dir[ "#{ path }/*" ].each do | each |
      if( File.file?( each ) and ( not mac_address_file_regex=~ File.basename( each ) ) )
        return File.basename( each )
      end
    end
    return nil
  end


  def load_network_config
    unless mac_address_file
      raise "MAC address for node '#{ @name }' not defined."
    end
    @mac_address = mac_address_file.gsub( '_', ':' )
    File.open( File.join( path, mac_address_file ) ) do | file |
      file.read.each_line do | each |
        variable, value = each.chomp.split( ':' )
        instance_variable_set "@#{ variable }".to_sym, value
      end
    end
  end


  def == another
    return( another.is_a?( Node ) and another.name == self.name )
  end


  private


  def mac_address_file
    Dir[ "#{ path }/*" ].collect do | each |
      mac_address_file_regex=~ File.basename( each )
      $1
    end.compact.first
  end


  def mac_address_file_regex
    hex = /[a-fA-F0-9][a-fA-F0-9]/
    return /\A(#{ hex }_#{ hex }_#{ hex }_#{ hex }_#{ hex }_#{ hex })\Z/
  end
end
