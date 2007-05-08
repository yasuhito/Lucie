#
# $Id: dselect-upgrade.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2

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
### indent-tabs-mode: nil
### End:
