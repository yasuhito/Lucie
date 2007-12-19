require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


ENV[ 'RAILS_ENV' ] = 'test'

require File.dirname( __FILE__ ) + '/../config/boot'
require RAILS_ROOT + '/config/environment'


################################################################################
# helper methods
################################################################################


def add_fresh_node node_name
  node_dir = File.join( './nodes', node_name )

  FileUtils.rm_rf node_dir
  FileUtils.mkdir node_dir
end


def cleanup_installers
  FileUtils.rm_rf Dir.glob( './installers/*' )
end


def cleanup_nodes
  FileUtils.rm_rf Dir.glob( './nodes/*' )
end


def output_with command
  Popen3::Shell.open do | shell |
    stdout = ''
    stderr = ''

    shell.on_stdout do | line |
      stdout << line
    end

    shell.on_stderr do | line |
      stderr << line
    end

    shell.exec( { 'LC_ALL' => 'C' }, command )

    [ stdout, stderr ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
