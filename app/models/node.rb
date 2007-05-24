class Node
  attr_reader :name
  attr_reader :mac_address
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


  def install_with installer_name
    FileUtils.touch File.join( @path, installer_name )
  end


  def installer_name
    Dir[ "#{ path }/*" ].each do | each |
      unless ( mac_address_re=~ File.basename( each ) )
        return File.basename( each )
      end
    end
    return nil
  end


  def load_mac_address
    mac_address_file = Dir[ "#{ path }/*" ].collect do | each |
      mac_address_re=~ File.basename( each )
      $1
    end.first
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
