module Command
  module NodeInstallMulti
    class Options < Command::Option
      usage "node install-multi <\"NODE-OPTIONS\" ...> --netmask=<NETMASK> --ldb-repository=<REPOSITORY-URL> [OPTIONS ...]"

      add_option( :long_option => "--netmask",
                  :short_option => "-n",
                  :argument => "[NETMASK-ADDRESS]",
                  :description => "Netmask address.",
                  :mandatory => true )
      add_option( :long_option => "--ldb-repository",
                  :short_option => "-L",
                  :argument => "[REPOSITORY-URL]",
                  :description => "LDB repository URL.",
                  :mandatory => true )

      separator

      add_option( :long_option => "--storage-conf",
                  :short_option => "-s",
                  :argument => "[FILE]",
                  :description => "setup-storage configuration file." )
      add_option( :long_option => "--http-proxy",
                  :short_option => "-H",
                  :argument => "[PROXY-URL]",
                  :description => "HTTP proxy url." )
      add_option( :long_option => "--package-repository",
                  :short_option => "-P",
                  :argument => "[REPOSITORY-URL]",
                  :description => "Package repository url." )
      add_option( :long_option => "--suite",
                  :short_option => "-S",
                  :argument => "[CODE-NAME]",
                  :description => "Distribution version code name (e.g., etch, stable etc.)." )
      add_option( :long_option => "--installer-linux-image",
                  :short_option => "-i",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package used while installation." )
      add_option( :long_option => "--linux-image",
                  :short_option => "-l",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package (e.g., linux-image-686) to be installed." )

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
