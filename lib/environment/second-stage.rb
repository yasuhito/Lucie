require "service"


module Environment
  class SecondStage
    def initialize debug_options
      @tftp_service = Service::Tftp.new( debug_options )
    end


    def start node
      @tftp_service.setup_localboot node
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
