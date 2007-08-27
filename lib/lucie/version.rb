module Lucie
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR = 0
      MINOR = 1
      MAINTENANCE = 0

      STRING = [ MAJOR, MINOR, MAINTENANCE ].join( '.' )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
