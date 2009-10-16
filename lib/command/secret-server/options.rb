require "command/option"


module Command
  module SecretServer
    class Options < Command::Option
      usage "./script/secret-server --secret <FILE> [OPTIONS ...]"

      add_option( :long_option => "--secret",
                  :short_option => "-X",
                  :argument => "[FILE]",
                  :description => "AES-256 encrypted file containing confidential data (e.g., passwords, private keys etc.).",
                  :mandatory => true )

      separator

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


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
