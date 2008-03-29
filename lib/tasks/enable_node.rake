require 'rake'


task 'lucie:enable_node' do
  nodes = ENV[ 'NODE_NAME' ] ? ENV[ 'NODE_NAME' ].split( /\s+/ ) : []
  installer_name = ENV[ 'INSTALLER_NAME' ]

  if nodes.empty?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  if installer_name.nil?
    raise MandatoryOptionError, "Installer name for node #{ nodes.join( ', ' ) } not defined."
  end

  nodes.each do | each |
    unless Nodes.find( each )
      raise "Node '#{ each }' is not added yet."
    end
  end
  unless Installers.find( installer_name )
    raise "Installer '#{ installer_name }' is not added yet."
  end

  lucie_daemon = LucieDaemon.server

  Lucie::Log.debug "Enabling node #{ nodes.join( ', ' ) }"
  lucie_daemon.enable_nodes nodes, installer_name

  Lucie::Log.debug 'Setting up TFTP daemon'
  lucie_daemon.setup_tftp nodes, installer_name

  Lucie::Log.debug 'Setting up NFS daemon'
  lucie_daemon.setup_nfs

  Lucie::Log.debug 'Setting up DHCP daemon'
  lucie_daemon.setup_dhcp

  Lucie::Log.debug 'Setting up Puppet daemon'
  lucie_daemon.setup_puppet installer_name

  if ENV[ 'WOL' ]
    # [FIXME] temporary disable wol feature.
    $stderr.puts "WOL feature is disabled."
    # Lucie::Log.debug 'Sending Wake on Lan magick packets'
    # lucie_daemon.wol nodes
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
