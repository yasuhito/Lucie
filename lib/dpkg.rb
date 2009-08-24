class Dpkg
  def installed? package
    FileTest.file? "/var/lib/dpkg/info/#{ package }.md5sums"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
