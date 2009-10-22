require "command/app"
require "lucie/logger/installer"


module Command
  module NodeHistory
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main node_name
        node = Node.new( node_name )
        dir = Lucie::Logger::Installer.log_directory( node )
        hist = Dir[ "#{ dir }/install-*" ].collect do | each |
          Status::Installer.new each, @debug_options, @debug_options[ :messenger ]
        end
        hist.each do | each |
          puts "#{ File.basename( each.path ) }: #{ each.to_s } in #{ each.elapsed_time } sec."
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
