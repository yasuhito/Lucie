require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


################################################################################
# helper methods
################################################################################


def add_fresh_node node_name
  node_dir = File.join( './nodes', node_name )

  FileUtils.rm_rf node_dir
  FileUtils.mkdir node_dir
end


def cleanup_nodes
  FileUtils.rm_rf Dir.glob( './nodes/*' )
end


def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
