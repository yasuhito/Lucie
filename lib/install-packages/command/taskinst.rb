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

# taskinst ¥³¥Þ¥
def taskinst( packageList )
  taskinst_command = InstallPackages::Command::Taskinst.new( packageList )
  InstallPackages::App.register taskinst_command
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
