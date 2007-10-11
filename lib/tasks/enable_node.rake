require 'rake'


task 'lucie:enable_node' do
  node_name = ENV[ 'NODE_NAME' ]
  installer_name = ENV[ 'INSTALLER_NAME' ]

  puts "Setting up installer '#{ installer_name }' for node '#{ node_name }' (this may take a while)..."

  node = Nodes.find( node_name )
  node.install_with installer_name
    
  Tftp.setup node.name, node.installer_name
  Nfs.setup node.installer_name
  Dhcp.setup node.installer_name, node.ip_address, node.netmask_address, node.gateway_address
  Puppet.setup Installers.find( node.installer_name ).local_checkout
    
  if ENV[ 'WOL' ]
    WakeOnLan.wake node.mac_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
