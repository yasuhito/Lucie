def add_fresh_node node_name, options = {}
  node_dir = File.join( Configuration.nodes_directory, node_name )
  unless FileTest.exists?( node_dir )
    Dir.mkdir node_dir
  end

  File.open( File.join( node_dir, '00_00_00_00_00_00' ), 'w' ) do | file |
    file.puts <<-EOF
gateway_address:192.168.0.254
ip_address:192.168.0.1
netmask_address:255.255.255.0
EOF
  end

  if options[ :installer ]
    FileUtils.touch File.join( node_dir, options[ :installer ] )
  end
end
