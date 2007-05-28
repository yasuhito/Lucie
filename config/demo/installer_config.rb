# Installer-specific configuration for Lucie


Nfsroot.configure do | nfsroot |

  # Build the nfsroot using http proxy "http://proxy.mydomain.com:3128"
  # nfsroot.http_proxy = 'http://proxy.mydomain.com:3128/'

  # Build the nfsroot using package mirror server "http://cdn.debian.or.jp/debian/"
  nfsroot.mirror = 'http://foo/bar/'

  # Build the nfsroot for "debian" Linux distribution
  # nfsroot.distribution = 'debian'

  # Set a version name of the Linux distribution
  # nfsroot.suite = 'etch'

  # Build the nfsroot with "linux-image-2.6.18-fai-kernels_1_i386.deb" kernel package in kernels/ directory.
  # nfsroot.kernel_package = 'linux-image-2.6.18-fai-kernels_1_i386.deb'

  # Use the following sources_list while installation (default: "http://192.168.1.1:9999/debian main contrib non-free")
  # Keep in mind that specified sources_list should be reachable from all nodes.
  # nfsroot.sources_list = 'deb http://192.168.1.1:9999/debian main contrib non-free'

end
