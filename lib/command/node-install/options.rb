require "command/option"


module Command
  module NodeInstall
    class Options < Command::Option
      usage "node install <NODE> --mac <MAC-ADDRESS> --storage-conf <FILE> --netmask <NETMASK> [OPTIONS ...]"

      add_option( :long_option => "--mac",
                  :short_option => "-m",
                  :argument => "[MAC-ADDRESS]",
                  :mandatory => true,
                  :description => "MAC address of network device." )
      add_option( :long_option => "--storage-conf",
                  :short_option => "-s",
                  :argument => "[FILE]",
                  :description => "setup-storage configuration file." )
      add_option( :long_option => "--netmask",
                  :short_option => "-n",
                  :argument => "[NETMASK-ADDRESS]",
                  :description => "Netmask address." )
      add_option( :long_option => "--ip-address",
                  :short_option => "-I",
                  :argument => "[IP-ADDRESS]",
                  :description => "IP address." )

      separator

      add_option( :long_option => "--ldb-repository",
                  :short_option => "-L",
                  :argument => "[URL]",
                  :description => "LDB repository URL." )

      add_option( :long_option => "--source-control",
                  :short_option => "-c",
                  :argument => "[SCM]",
                  :description => "Specify the source control manager to use (default: Mercurial)" )

      add_option( :long_option => "--secret",
                  :short_option => "-X",
                  :argument => "[FILE]",
                  :description => %{AES-256 encrypted file containing confidential data (for example, passwords, private keys etc.).} )

      separator

      add_option( :long_option => "--linux-image",
                  :short_option => "-l",
                  :argument => "[PACKAGE]",
                  :description => %{Linux image package (for example, "linux-image-686") to be installed.} )
      add_option( :long_option => "--installer-linux-image",
                  :short_option => "-i",
                  :argument => "[PACKAGE]",
                  :description => "Linux image package used while installation." )
      add_option( :long_option => "--suite",
                  :short_option => "-S",
                  :argument => "[CODENAME]",
                  :description => %{Distribution version code name (for example, "etch", "stable").} )
      add_option( :long_option => "--architecture",
                  :short_option => "-a",
                  :argument => "[ARCHITECTURE]",
                  :description => %{Architecture of packages Lucie installs (for example, "i386", "amd64").} )

      separator

      add_option( :long_option => "--http-proxy",
                  :short_option => "-H",
                  :argument => "[URL]",
                  :description => "HTTP proxy url." )
      add_option( :long_option => "--package-repository",
                  :short_option => "-P",
                  :argument => "[URL]",
                  :description => %{Package repository url (for example, "http://www.debian.or.jp/debian/").} )

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
