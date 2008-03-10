require 'rake'


task 'lucie:disable_node' do
  node_name = ENV[ 'NODE_NAME' ]

  if node_name.nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  unless Nodes.find( node_name )
    raise "Node '#{ node_name }' is not added yet."
  end

  lucie_daemon = LucieDaemon.server
  lucie_daemon.disable_node( node_name )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
