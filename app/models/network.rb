class Network
  def self.network_address address, netmask
    result = []
    [ 0, 1, 2, 3 ].each do | each |
      result << ( address.split( '.' )[ each ].to_i & netmask.split( '.' )[ each ].to_i )
    end
    return result.join( '.' )
  end


  def self.broadcast_address address, netmask
    result = []
    [ 0, 1, 2, 3 ].each do | each |
      result << ( ( ~netmask.split( '.' )[ each ].to_i & 255 ) | network_address( address, netmask ).split( '.' )[ each ].to_i )
    end
    return result.join( '.' )
  end
end
