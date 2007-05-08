#
# $Id: taskrm.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2

module InstallPackages
  module Command
    class Taskrm < AbstractCommand
      public
      def commandline
        return @list.map do |each|
          %{#{root_command} tasksel -n remove #{each}}
        end
      end
    end
  end
end

# taskrm コマンド
def taskrm( packageList )
  taskrm_command = InstallPackages::Command::Taskrm.new( packageList )
  InstallPackages::App.register( taskrm_command )
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
