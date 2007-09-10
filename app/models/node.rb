class Node
  attr_reader :install_command
  attr_reader :mac_address
  attr_reader :name
  attr_reader :path


  def self.read dir, load_config = true
    @node_in_the_works = Node.new( File.basename( dir ) )
    begin
      if load_config
        @node_in_the_works.load_config
      end
      return @node_in_the_works
    ensure
      @node_in_the_works = nil
    end
  end


  def initialize name, mac_address = nil
    @name = name
    @mac_address = mac_address
    @path = File.join( Configuration.nodes_directory, @name )
    unless @mac_address
      load_mac_address
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
      if( File.file?( each ) and ( not mac_address_re=~ File.basename( each ) ) )
        return File.basename( each )
      end
    end
    return nil
  end


  def load_mac_address
    mac_address_file = Dir[ "#{ path }/*" ].collect do | each |
      mac_address_re=~ File.basename( each )
      $1
    end.compact.first
    unless mac_address_file
      raise "MAC address for node '#{ @name }' not defined."
    end
    @mac_address = mac_address_file
  end


  def == another
    return( another.is_a?( Node ) and another.name == self.name )
  end


  # XXX needs NodeConfigTracker?
  def path= value
    # @config_tracker = NodeConfigTracker.new( value )
    @path = value
  end


  private


  def mac_address_re
    hex = /[a-fA-F0-9][a-fA-F0-9]/
    return /\A(#{hex}:#{hex}:#{hex}:#{hex}:#{hex}:#{hex})\Z/
  end
end
