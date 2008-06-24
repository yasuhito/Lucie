require 'rake'


task 'lucie:remove_node' do
  nodes = ENV[ 'NODE_NAME' ] ? ENV[ 'NODE_NAME' ].split( /\s+/ ) : []

  if nodes.nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  nodes.each do | each |
    unless Nodes.find( each )
      raise "Node '#{ each }' not found."
    end
  end

  lucie_daemon = LucieDaemon.server

  Lucie::Log.debug 'Removing TFTP setting'
  lucie_daemon.remove_tftp nodes

  nodes.each do | each |
    Nodes.remove! each
  end

  Lucie::Log.debug 'Setting up DHCP daemon'
  lucie_daemon.setup_dhcp

  Lucie::Log.debug 'Setting up NFS daemon'
  lucie_daemon.setup_nfs
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
