require "configurator/client"
require "configurator/server"


module Configurator
  def self.convert url
    url.gsub( /[\/:@]/, "_" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
