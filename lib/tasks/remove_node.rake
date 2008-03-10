require 'rake'


task 'lucie:remove_node' do
  node_name = ENV[ 'NODE_NAME' ]

  if node_name.nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  unless Nodes.find( node_name )
    raise "Node '#{ node_name }' not found."
  end

  lucie_daemon = LucieDaemon.server

  Lucie::Log.debug 'Setting up DHCP daemon'
  lucie_daemon.setup_dhcp

  Lucie::Log.debug 'Setting up NFS daemon'
  lucie_daemon.setup_nfs

  Lucie::Log.debug 'Removing TFTP setting'
  lucie_daemon.remove_tftp node_name

  Nodes.remove! node_name
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
