#
# $Id: taskinst.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2

module InstallPackages
  module Command
    class Taskinst < AbstractCommand
      public
      def commandline
        return @list.map do |each|
          %{#{root_command} tasksel -n install #{each}}
        end
      end
    end
  end
end

# taskinst コマンド
def taskinst( packageList )
  taskinst_command = InstallPackages::Command::Taskinst.new( packageList )
  InstallPackages::App.register taskinst_command
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
