#
# NOTE: Please require this file first before other lib/**/*.rb are required.
#
# e.g.
#   require 'lucie'
#   require 'foo'
#   require 'bar'
#      ...
#


$LOAD_PATH.unshift( File.expand_path( File.dirname( __FILE__ ) + "/../vendor/ruby-ifconfig-1.2/lib/" ) )


module Lucie
  ROOT = File.expand_path( File.join( File.dirname( __FILE__ ), ".." ) )
end
