require 'rake'


task 'lucie:enable_node' do
  node_name = ENV[ 'NODE_NAME' ]
  installer_name = ENV[ 'INSTALLER_NAME' ]

  if node_name.nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  if installer_name.nil?
    raise MandatoryOptionError, "Installer name for node '#{ node_name }' not defined."
  end
  unless Nodes.find( node_name )
    raise "Node '#{ node_name }' is not added yet."
  end
  unless Installers.find( installer_name )
    raise "Installer '#{ installer_name }' is not added yet."
  end

  lucie_daemon = LucieDaemon.server

  Lucie::Log.debug "Enabling node #{ node_name }"
  lucie_daemon.enable_node node_name, installer_name

  Lucie::Log.debug 'Setting up TFTP daemon'
  lucie_daemon.setup_tftp node_name, installer_name

  Lucie::Log.debug 'Setting up NFS daemon'
  lucie_daemon.setup_nfs

  Lucie::Log.debug 'Setting up DHCP daemon'
  lucie_daemon.setup_dhcp

  Lucie::Log.debug 'Setting up Puppet daemon'
  lucie_daemon.setup_puppet installer_name

  if ENV[ 'WOL' ]
    Lucie::Log.debug 'Sending Wake on Lan magick packets'
    lucie_daemon.wol node_name
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
