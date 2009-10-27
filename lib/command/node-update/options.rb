require "command/option"


module Command
  module NodeUpdate
    class Options < Command::Option
      usage "node update <NODES ...> [OPTIONS ...]"

      add_option( :long_option => "--secret",
                  :short_option => "-X",
                  :argument => "[FILE]",
                  :description => "AES-256 encrypted file containing confidential data (e.g., passwords, private keys etc.)." )
      add_option( :long_option => "--ldb-repository",
                  :short_option => "-L",
                  :argument => "[REPOSITORY-URL]",
                  :description => "LDB repository URL." )
      add_option( :long_option => "--source-control",
                  :short_option => "-c",
                  :argument => "[SCM]",
                  :description => "Specify the source control manager to use (default: Mercurial)" )

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
