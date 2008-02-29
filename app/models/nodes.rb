class Nodes
  def self.load_all installer_name = nil
    return Nodes.new( Configuration.nodes_directory ).load_all( installer_name )
  end


  def self.load_enabled installer_name
    Nodes.new( Configuration.nodes_directory ).load_enabled( installer_name )
  end


  def self.path node_name
    File.join( Configuration.nodes_directory, node_name )
  end


  def self.remove! node_name
    unless File.directory?( path( node_name ) )
      raise "Node '#{ node_name }' not found."
    end
    FileUtils.rm_rf path( node_name )
  end


  def self.find node_name
    # TODO: sanitize node_name to prevent a query injection attack here
    unless File.directory?( path( node_name ) )
      return nil
    end
    load_node path( node_name )
  end


  def self.load_node dir
    node = Node.read( dir )
    return node
  end


  attr_reader :dir
  attr_reader :list


  def initialize dir = Configuration.nodes_directory
    @dir = dir
    @list = []
  end


  def load_enabled installer_name
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      enabled = Dir[ child + "/*" ].find_all do | each |
        installer_name == File.basename( each )
      end
      ( not enabled.empty? ) and File.directory?( child )
    end.collect do | child |
      Nodes.load_node child
    end
    return self
  end


  def load_all installer_name
    @list = Dir[ "#{ @dir }/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      node = Nodes.load_node( child )
      if installer_name and ( node.installer_name != installer_name )
        nil
      else
        node
      end
    end.compact
    return self
  end


  def << node
    Lucie::Log.debug "Adding node #{ node.name }"

    if @list.include?( node )
      raise "Node '#{ node.name }' already exists."
    end
    @list << node
    save_node node
    write_config node
    self
  end


  def save_node node
    node.path = File.join( @dir, node.name )
    FileUtils.mkdir_p node.path
  end


  def write_config node
    mac_address_config = File.join( node.path, node.mac_address.gsub( ':', '_' ) )

    File.open( mac_address_config, 'w' ) do | f |
      f.puts <<-EOF
gateway_address:#{ node.gateway_address }
ip_address:#{ node.ip_address }
netmask_address:#{ node.netmask_address }
EOF
    end
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
