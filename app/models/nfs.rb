#
# NFS daemon controller class
#

require 'ftools'
require 'popen3/shell'


class Nfs
  def self.setup
    self.new.setup
  end


  def setup
    File.copy config_file, config_file + '.old'

    File.open( config_file, 'w' ) do | file |
      enabled_nodes.each do | each |
        file.puts "# #{ each.name }"
        file.puts "#{ Installer.path( each.installer_name ) } #{ each.ip_address }(async,ro,no_root_squash,no_subtree_check)"
      end
    end

    if nfsd_is_down
      sh_exec '/etc/init.d/nfs-kernel-server start'
    else
      sh_exec '/etc/init.d/nfs-kernel-server reload'
    end
  end


  ################################################################################
  private
  ################################################################################


  def nfsd_is_down
    not system( "ps -U root -u root | grep nfsd" )
  end


  def enabled_nodes
    Nodes.load_all.select do | each |
      each.enable?
    end
  end


  def config_file
    return '/etc/exports'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
