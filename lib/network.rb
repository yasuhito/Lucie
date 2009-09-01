class Network
  def self.network_address address, netmask
    begin
      result = []
      [ 0, 1, 2, 3 ].each do | each |
        result << ( address.split( '.' )[ each ].to_i & netmask.split( '.' )[ each ].to_i )
      end
      result.join( '.' )
    rescue
      nil
    end
  end


  def self.broadcast_address address, netmask
    result = []
    [ 0, 1, 2, 3 ].each do | each |
      result << ( ( ~netmask.split( '.' )[ each ].to_i & 255 ) | network_address( address, netmask ).split( '.' )[ each ].to_i )
    end
    return result.join( '.' )
  end


  def self.subnet_includes? subnet_a, subnet_b
    return false unless subnet_a
    [ 0, 1, 2, 3 ].inject( true ) do | result, oidx |
      if subnet_a.split( "." )[ oidx ] == "0"
        result
      else
        result &= subnet_a.split( "." )[ oidx ] == subnet_b.split( "." )[ oidx ]
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
