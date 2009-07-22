require "command/option"


module Command
  module NodeUpdate
    class Options < Command::Option
      usage "node update <NODES ...> [OPTIONS ...]"

      add_option( :long_option => "--help",
                  :short_option => "-h",
                  :description => "Show this help message." )
      add_option( :long_option => "--dry-run",
                  :short_option => "-d",
                  :description => "Print the commands that would be executed, but do not execute them." )
      add_option( :long_option => "--verbose",
                  :short_option => "-v",
                  :description => "Be verbose." )
    end
  end
end
