#
# nfs.rb - setups NFS server
#
# methods:
#   Nfs.setup - setups NFS server
#


require 'ftools'
require 'popen3/shell'


class Nfs
  def self.setup
    self.new.__send__ :setup
  end


  ################################################################################
  private
  ################################################################################


  def setup
    unless nfs_installed
      raise 'nfs-kernel-server package is not installed. Please install first.'
    end

    if enabled_nodes.empty?
      # do nothing.
      return
    end

    generate_config_file

    if nfsd_is_down
      sh_exec '/etc/init.d/nfs-kernel-server start'
    else
      sh_exec '/etc/init.d/nfs-kernel-server reload'
    end
  end


  def generate_config_file
    File.copy config_file, config_file + '.old'
    File.open( config_file, 'w' ) do | file |
      enabled_nodes.each do | each |
        file.puts "# #{ each.name }"
        file.puts "#{ Installer.path( each.installer_name ) } #{ each.ip_address }(async,ro,no_root_squash,no_subtree_check)"
      end
    end
  end


  def nfs_installed
    File.exists? '/etc/init.d/nfs-kernel-server'
  end


  def nfsd_is_down
    not system( "ps -U root -u root | grep nfsd" )
  end


  def enabled_nodes
    Nodes.load_all.select do | each |
      each.enable?
    end
  end


  def config_file
    '/etc/exports'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
