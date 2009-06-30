require "service"


module Environment
  class FirstStage
    def initialize options, messenger
      @options = options
      @messenger = messenger
    end


    def start nodes, installer, interfaces = nil
      Service::Installer.new( @options, @messenger ).setup nodes, installer
      Service::Approx.new( @options, @messenger ).setup
      Service::Tftp.new( @options, @messenger ).setup_nfsroot nodes, installer
      Service::Nfs.new( @options, @messenger ).setup nodes, installer
      Service::Dhcp.new( @options, @messenger ).setup nodes, interfaces
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
