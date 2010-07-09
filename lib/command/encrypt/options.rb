require "command/option"


module Command
  module Encrypt
    class Options < Command::Option
      usage "encrypt [OPTIONS ...] <FILE>"

      add_option( :long_option => "--password",
                  :short_option => "-p",
                  :argument => "[STRING]",
                  :description => "A password to encrypt input file" )

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
### coding: utf-8
### indent-tabs-mode: nil
### End:
