class Nfs
  def self.setup installer_name
    nodes = Nodes.load_enabled( installer_name ).collect do | each |
      each.name
    end.join( ',' )

    config_file = "/etc/exports.#{ installer_name }"

    File.open( config_file, 'w' ) do | file |
      file.puts File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot #{ nodes }(async,ro,no_root_squash,no_subtree_check)" )
    end

    # TODO: Reconfigure NFS daemon automatically
    puts "File #{ config_file } generated SUCCESSFULLY"
    puts " Please replace your /etc/exports file and restart NFS daemon manually."
    puts " % cp #{ config_file } /etc/exports && /etc/init.d/nfs-kernel-server restart"
  end
end
