module InstallPackages
  module Command
    class DselectUpgrade < AbstractCommand
      public
      def go
        unless $dry_run
          File.open( tempfile, 'w' ) do |file|
            @list.each do |each|
              file.puts( each[:package] + ' ' + each[:action] )
            end
          end
        end
        super
      end

      public
      def commandline
        return [%{#{root_command} dpkg --set-selections < #{tempfile}},
          %{#{root_command} apt-get #{APT_OPTION} dselect-upgrade},
          %{rm #{tempfile}}]
      end
      
      # TODO: use better uniq filename
      private
      def tempfile
        return %{/tmp/target/tmp/dpkg-selections.tmp}
      end
    end
  end
end

# dselect-upgrade コマンド
def dselect_upgrade( &block )
  dselect_upgrade_command = InstallPackages::Command::DselectUpgrade.new
  block.call( dselect_upgrade_command )
  InstallPackages::App.register dselect_upgrade_command
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
