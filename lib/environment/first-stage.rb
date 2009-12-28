require "lucie/io"
require "lucie/server"
require "service"


module Environment
  #
  # A controller class of network boot services. This class
  # automatically reconfigure and restart services so that nodes can
  # start first stage installer.
  #
  class FirstStage
    include Lucie::IO


    #
    # Returns a new <tt>Environment::FirstStage</tt> object that
    # automatically configures daemons and build an installer for
    # network boot.
    #
    # Nodes that are going to be installed are specified with +nodes+,
    # and the installer that is used while installation is
    # +installer+.
    #
    # Options: verbose dry_run messenger nic inetd_conf
    #
    def initialize nodes, installer, debug_options
      @nodes = nodes
      @installer = installer
      @debug_options = debug_options
    end


    #
    # Reconfigure services and restart if need be.
    #
    def start
      setup_installer
      setup_approx
      setup_tftp
      setup_nfs
      setup_dhcp
    end


    ############################################################################
    private
    ############################################################################


    def setup_installer
      info "Setting up installer ..."
      Service::Installer.new( @debug_options ).setup @installer, Lucie::Server.ip_address_for( @nodes, @debug_options )
    end


    def setup_approx
      info "Setting up approx ..."
      Service::Approx.new( @debug_options ).setup @installer.package_repository
    end


    def setup_tftp
      info "Setting up tftpd ..."
      Service::Tftp.new( @debug_options ).setup_networkboot @nodes, @installer
    end


    def setup_nfs
      info "Setting up nfsd ..."
      Service::Nfs.new( @debug_options ).setup @nodes, @installer.path
    end


    def setup_dhcp
      info "Setting up dhcpd ..."
      Service::Dhcp.new( @debug_options ).setup @nodes
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
