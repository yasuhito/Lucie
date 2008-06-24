require 'rake'


task 'lucie:disable_node' do
  nodes = ENV[ 'NODE_NAME' ] ? ENV[ 'NODE_NAME' ].split( /\s+/ ) : []

  if nodes.nil?
    raise MandatoryOptionError, 'Node name not defined.'
  end
  nodes.each do | each |
    unless Nodes.find( each )
      raise "Node '#{ each }' is not added yet."
    end
  end

  lucie_daemon = LucieDaemon.server
  lucie_daemon.disable_node( nodes )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
