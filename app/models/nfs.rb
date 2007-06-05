class Nfs
  def self.setup installer_name
    nodes = Nodes.load_enabled( installer_name ).collect do | each |
      each.name
    end.join( ',' )

    config_file = "/etc/exports.#{ installer_name }"

    File.open( config_file, 'w' ) do | file |
      file.puts File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot #{ nodes }(async,ro,no_root_squash)" )
    end

    puts "File #{ config_file } generated SUCCESSFULLY"
  end
end
