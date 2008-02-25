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
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
