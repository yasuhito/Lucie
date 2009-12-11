require "command/option"


module Command
  module ConfidentialDataServer
    class Options < Command::Option
      usage "./script/confidential-data-server --encrypted-file <FILE> [OPTIONS ...]"

      add_option( :long_option => "--encrypted-file",
                  :short_option => "-e",
                  :argument => "[FILE]",
                  :description => "AES-256 encrypted file containing confidential data (e.g., passwords, private keys etc.).",
                  :mandatory => true )

      separator

      add_option( :long_option => "--password",
                  :short_option => "-P",
                  :argument => "[PASSWORD]",
                  :description => "A password to decrypt the encrypted confidential data" )
      add_option( :long_option => "--port",
                  :short_option => "-p",
                  :argument => "[NUM]",
                  :description => "Specify the port on which the server listens for connections (default #{ ::ConfidentialDataServer::PORT })" )

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
