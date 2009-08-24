class Dpkg
  def installed? package
    FileTest.file? "/var/lib/dpkg/info/#{ package }.md5sums"
  end
end
