module InstallPackages
  module AptPackageManager
    def apt_option
      return %{-y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
