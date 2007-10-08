require 'rake'


task 'lucie:add_node' do
  STDOUT.puts "Adding node '#{ ENV[ 'NODE_NAME' ] }' (this may take a while)..."

  if ENV[ 'MAC_ADDRESS' ].nil?
    raise "MAC address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'IP_ADDRESS' ].nil?
    raise "IP address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'GATEWAY_ADDRESS' ].nil?
    raise "Gateway address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  if ENV[ 'NETMASK_ADDRESS' ].nil?
    raise "Netmask address for node '#{ ENV[ 'NODE_NAME' ] }' not defined."
  end

  node = Node.new( ENV[ 'NODE_NAME' ], { :mac_address => ENV[ 'MAC_ADDRESS' ], :gateway_address => ENV[ 'GATEWAY_ADDRESS' ], :ip_address => ENV[ 'IP_ADDRESS' ], :netmask_address => ENV[ 'NETMASK_ADDRESS' ] } )
  nodes = Nodes.load_all
  nodes << node
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
