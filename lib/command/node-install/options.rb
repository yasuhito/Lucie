require "command/option"


module Command
  module NodeInstall
    class Options < Command::Option
      usage "node install <NODE> --mac <MAC-ADDRESS> --storage-conf <FILE> --netmask <NETMASK> [OPTIONS ...]"

      add_option( :long_option => "--mac",
                  :short_option => "-m",
                  :argument => "[MAC-ADDRESS]",
                  :mandatory => true,
                  :description => "MAC address of eth0 device." )
      add_option( :long_option => "--storage-conf",
                  :short_option => "-s",
                  :argument => "[FILE]",
                  :description => "setup-storage configuration file."
                  )
      add_option( :long_option => "--netmask",
                  :short_option => "-n",
                  :argument => "[NETMASK-ADDRESS]",
                  :description => "Netmask address." )

      separator

      add_option( :long_option => "--ldb-repository",
                  :short_option => "-L",
                  :argument => "[REPOSITORY-URL]",
                  :description => "LDB repository URL." )

      separator

      add_option( :long_option => "--installer-linux-image",
                  :short_option => "-i",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package used while installation." )
      add_option( :long_option => "--linux-image",
                  :short_option => "-l",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package (e.g., linux-image-686) to be installed." )
      add_option( :long_option => "--suite",
                  :short_option => "-S",
                  :argument => "[CODE-NAME]",
                  :description => "Distribution version code name (e.g., etch, stable etc.)." )

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

      add_option( :long_option => "--eth1",
                  :short_option => "-1",
                  :argument => "[MAC-ADDRESS]",
                  :description => "MAC address of eth1 device." )
      add_option( :long_option => "--eth2",
                  :short_option => "-2",
                  :argument => "[MAC-ADDRESS]",
                  :description => "MAC address of eth2 device." )
      add_option( :long_option => "--eth3",
                  :short_option => "-3",
                  :argument => "[MAC-ADDRESS]",
                  :description => "MAC address of eth3 device." )
      add_option( :long_option => "--eth4",
                  :short_option => "-4",
                  :argument => "[MAC-ADDRESS]",
                  :description => "MAC address of eth4 device." )

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
