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
      nodes.each do | each |
        file.puts "#{ nfsroot( each.installer_name ) } #{ each.name }(async,ro,no_root_squash,no_subtree_check)"
      end
    end

    sh_exec '/etc/init.d/nfs-kernel-server restart'
  end


  ################################################################################
  private
  ################################################################################


  # [FIXME] Get nfsroot path from Nfsroot class
  def nfsroot installer_name
    File.join( Configuration.installers_directory, installer_name, 'nfsroot' )
  end


  def nodes
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
