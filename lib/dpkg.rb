class Dpkg
  def initialize debug_options = {}
    @debug_options = debug_options
  end


  def installed? package
    if @debug_options[ :dpkg ]
      @debug_options[ :dpkg ].installed?( package )
    else
      FileTest.file? "/var/lib/dpkg/info/#{ package }.md5sums"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
