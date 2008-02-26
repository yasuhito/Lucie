require 'facter'


def dummy_ip_address
  my_address = Facter.value( 'ipaddress' )
  /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/ =~ my_address
  if $4.to_i < 253
    return "#{ $1 }.#{ $2 }.#{ $3 }.#{ $4.to_i + 1 }"
  else
    return "#{ $1 }.#{ $2 }.#{ $3 }.252"
  end
end


def dummy_gateway_address
  /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/ =~ dummy_ip_address
  return "#{ $1 }.#{ $2 }.#{ $3 }.254"
end


def add_fresh_node node_name
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
end


def enable_node node_name, installer_name
  FileUtils.touch File.join( Configuration.nodes_directory, node_name, installer_name )
end


def disable_node node_name
  Dir.glob( File.join( Configuration.nodes_directory, node_name, '*' ) ).each do | each |
    if File.file?( each ) and File.basename( each ) != '00_00_00_00_00_00'
      FileUtils.mv each, each + '.DISABLE'
    end
  end
end


def add_success_log node_name
  FileUtils.mkdir File.join( Configuration.nodes_directory, node_name, 'install-0' )
  FileUtils.touch File.join( Configuration.nodes_directory, node_name, 'install-0', 'install_status.success.in10s' )
end


def add_failure_log node_name
  FileUtils.mkdir File.join( Configuration.nodes_directory, node_name, 'install-0' )
  FileUtils.touch File.join( Configuration.nodes_directory, node_name, 'install-0', 'install_status.failed.in10s' )
end


def add_incomplete_log node_name
  FileUtils.mkdir File.join( Configuration.nodes_directory, node_name, 'install-0' )
  FileUtils.touch File.join( Configuration.nodes_directory, node_name, 'install-0', 'install_status.incomplete' )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
