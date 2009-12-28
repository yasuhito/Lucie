require "lucie/debug"


class Dpkg
  include Lucie::Debug


  def initialize debug_options = {}
    @debug_options = debug_options
  end


  def installed? package
    result = FileTest.file?( "/var/lib/dpkg/info/#{ package }.md5sums" )
    debug ( result ? "Checking #{ package } ... installed" : "Checking #{ package } ... not installed" )
    result
  end


  def installed_on? node, package
    if @debug_options[ :dpkg ]
      @debug_options[ :dpkg ].installed_on?( node, package )
    else
      ssh = SSH.new( @debug_options )
      ssh.sh node.ip_address, "test -f /var/lib/dpkg/info/#{ package }.md5sums"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
