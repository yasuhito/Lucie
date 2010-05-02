require "singleton"


module Service
  #
  # keeps a list of configuration files.
  #
  class ConfigManager
    include Singleton


    def initialize
      @list = {}
    end


    def add service, path
      @list[ service ] = path
    end


    def [] service
      @list[ service ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
