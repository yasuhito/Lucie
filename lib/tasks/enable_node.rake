require 'rake'


task 'lucie:enable_node' do
  node_name = ENV[ 'NODE_NAME' ]
  installer_name = ENV[ 'INSTALLER_NAME' ]

  if node_name.nil?
    raise "Node name not defined."
  end

  if installer_name.nil?
    raise "Installer name for node '#{ node_name }' not defined."
  end

  STDOUT.puts "Setting up installer '#{ installer_name }' for node '#{ node_name }' (this may take a while)..."

  node = Nodes.find( node_name )
  node.enable! installer_name

  Tftp.setup node.name, node.installer_name
  Nfs.setup node.installer_name
  Dhcp.setup node.installer_name, node.ip_address, node.netmask_address, node.gateway_address
  PuppetController.setup Installers.find( node.installer_name ).local_checkout

  if ENV[ 'WOL' ]
    WakeOnLan.wake node.mac_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
