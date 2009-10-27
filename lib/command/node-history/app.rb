require "command/app"
require "lucie/debug"
require "lucie/logger/installer"


module Command
  module NodeHistory
    class App < Command::App
      include Lucie::Debug


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main node_name
        install_history_sorted_by_id( node_name ).each do | each |
          show each
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def show status
        if status.broken?
          error "Failed to parse #{ status.label }. skipping ..."
        elsif status.incomplete?
          stdout.puts "#{ status.label }: #{ status.to_s }."
        else
          # success or fail
          stdout.puts "#{ status.label }: #{ status.to_s } in #{ status.elapsed_time } sec."
        end
      end


      def install_history_sorted_by_id node_name
        Node.load_install_history_of( node_name, @debug_options ).sort_by do | each |
          each.install_id
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
