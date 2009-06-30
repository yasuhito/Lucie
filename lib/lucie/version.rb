module Lucie
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR = 0
      MINOR = 4
      MAINTENANCE = 0

      STRING = [ MAJOR, MINOR, MAINTENANCE ].join( '.' )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
