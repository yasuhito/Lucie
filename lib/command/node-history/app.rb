require "command/app"
require "lucie/debug"
require "lucie/logger"
require "node"


module Command
  module NodeHistory
    class App < Command::App
      class Message
        def initialize status, colorize
          @status = status
          @colorize = colorize
        end


        ########################################################################
        private
        ########################################################################


        def maybe_colorize string, color
          if @colorize
            require "rubygems"
            require "termcolor"
            return TermColor.parse( "<#{ color }>#{ string }</#{ color }>" )
          end
          string
        end
      end


      class CompletedMessage < Message
        private
        def complete_message
          "install ##{ @status.install_id }: #{ @status.to_s } in #{ @status.elapsed_time } sec."
        end
      end


      class SucceededMessage < CompletedMessage
        def to_s
          maybe_colorize complete_message, :green
        end
      end


      class FailedMessage < CompletedMessage
        def to_s
          maybe_colorize complete_message, :red
        end
      end


      class IncompleteMessage < Message
        def to_s
          "install ##{ @status.install_id }: #{ @status.to_s }."
        end
      end


      class StatusErrorMessage < Message
        def to_s
          maybe_colorize "Failed to parse install ##{ @status.install_id } log. Skipping ...", :yellow
        end
      end


      include Lucie::Debug


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main node_name
        statuses_sort_by_install_id( node_name ).each do | each |
          show each
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def show status
        begin
          info message_for( status ).to_s + "\n"
        rescue Status::StatusError
          error StatusErrorMessage.new( status, @global_options.color )
        end
      end


      def message_for status
        message_types.each do | pred, klass |
          return klass.new( status, @global_options.color ) if status.__send__( pred )
        end
        raise Status::StatusError
      end


      def message_types
        { :incomplete? => IncompleteMessage,
          :succeeded? => SucceededMessage,
          :failed? => FailedMessage }
      end


      def statuses_sort_by_install_id node_name
        # [FIXME] The following should be written as 'Nodes.load( node_name, @debug_options ).install_history.sort_by ...' ??
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
