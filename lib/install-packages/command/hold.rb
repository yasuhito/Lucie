#
# $Id: hold.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2

module InstallPackages
  module Command
    class Hold < AbstractCommand
      public
      def commandline
        return @list.map do |each|
          %{echo #{each} hold | #{root_command} dpkg --set-selections}
        end
      end
    end 
  end
end

# hold コマンド
def hold( packageList )
  hold_command = InstallPackages::Command::Hold.new( packageList )
  InstallPackages::App.register hold_command
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
