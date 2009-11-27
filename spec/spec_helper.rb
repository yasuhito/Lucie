$: << File.join( File.dirname( __FILE__ ), "/../lib" )
$: << File.join( File.dirname( __FILE__ ), "/../vendor/ruby-ifconfig-1.2/lib" )


require "rubygems"
require "spec"

require "command/node-install-multi"
require "confidential-data-server"
require "configuration-updator"
require "configurator"
require "debootstrap"
require "lucie/server"
require "service"
require "super-reboot"
require "tempfile"


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
