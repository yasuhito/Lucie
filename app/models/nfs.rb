require 'ftools'


class Nfs
  def self.setup installer_name
    nodes = Nodes.load_enabled( installer_name ).collect do | each |
      each.name
    end.join( ',' )

    config_file = '/etc/exports'
    File.copy config_file, config_file + '.orig'

    File.open( config_file, 'w' ) do | file |
      file.puts File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot #{ nodes }(async,ro,no_root_squash,no_subtree_check)" )
    end
    puts "File #{ config_file } generated SUCCESSFULLY"
    system '/etc/init.d/nfs-kernel-server restart'
  end
end
