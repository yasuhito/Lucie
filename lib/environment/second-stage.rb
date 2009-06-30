require "service"


module Environment
  class SecondStage
    def initialize options, messenger
      @tftp_service = Service::Tftp.new( options, messenger )
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
