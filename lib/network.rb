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
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
