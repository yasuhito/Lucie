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
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
