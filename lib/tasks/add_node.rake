require 'rake'


task 'lucie:add_node' do
  if ENV[ 'NODE_NAME' ].nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end

  if ENV[ 'MAC_ADDRESS' ].nil?
    raise MandatoryOptionError, "MAC address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'IP_ADDRESS' ].nil?
    raise MandatoryOptionError, "IP address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'GATEWAY_ADDRESS' ].nil?
    raise MandatoryOptionError, "Gateway address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'NETMASK_ADDRESS' ].nil?
    raise MandatoryOptionError, "Netmask address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  node = Node.new( ENV[ 'NODE_NAME' ], { :mac_address => ENV[ 'MAC_ADDRESS' ], :gateway_address => ENV[ 'GATEWAY_ADDRESS' ], :ip_address => ENV[ 'IP_ADDRESS' ], :netmask_address => ENV[ 'NETMASK_ADDRESS' ] } )
  nodes = Nodes.load_all
  nodes << node
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
