require "command/option"


module Command
  module NodeInstallMulti
    class Options < Command::Option
      usage "node install-multi <\"NODE-OPTIONS\" ...> [GLOBAL-OPTIONS ...]"

      add_option( :long_option => "--netmask",
                  :short_option => "-n",
                  :argument => "[NETMASK-ADDRESS]",
                  :description => "Netmask address." )

      separator

      add_option( :long_option => "--storage-conf",
                  :short_option => "-s",
                  :argument => "[FILE]",
                  :description => "setup-storage configuration file." )
      add_option( :long_option => "--ldb-repository",
                  :short_option => "-L",
                  :argument => "[REPOSITORY-URL]",
                  :description => "LDB repository URL." )
      add_option( :long_option => "--source-control",
                  :short_option => "-c",
                  :argument => "[SCM]",
                  :description => "Specify the source control manager to use (default: Mercurial)" )
      add_option( :long_option => "--secret",
                  :short_option => "-X",
                  :argument => "[FILE]",
                  :description => "AES-256 encrypted file containing confidential data (e.g., passwords, private keys etc.)." )

      separator

      add_option( :long_option => "--linux-image",
                  :short_option => "-l",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package (e.g., linux-image-686) to be installed." )
      add_option( :long_option => "--suite",
                  :short_option => "-S",
                  :argument => "[CODE-NAME]",
                  :description => "Distribution version code name (e.g., etch, stable etc.)." )
      add_option( :long_option => "--architecture",
                  :short_option => "-a",
                  :argument => "[ARCHITECTURE]",
                  :description => %{Architecture of packages Lucie installs (for example, "i386", "amd64").} )

      separator

      add_option( :long_option => "--http-proxy",
                  :short_option => "-H",
                  :argument => "[PROXY-URL]",
                  :description => "HTTP proxy url." )
      add_option( :long_option => "--package-repository",
                  :short_option => "-P",
                  :argument => "[REPOSITORY-URL]",
                  :description => "Package repository url." )

      separator

      add_option( :long_option => "--help",
                  :short_option => "-h",
                  :description => "Show this help message." )
      add_option( :long_option => "--dry-run",
                  :short_option => "-d",
                  :description => "Print the commands that would be executed, but do not execute them." )
      add_option( :long_option => "--break",
                  :short_option => "-b",
                  :description => "Set a breakpoint." )
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
