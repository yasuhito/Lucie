require "service/tftp/config-file"


#
# A configuration file generator for local booting with TFTP.
#
class Service::Tftp::ConfigLocalBoot < Service::Tftp::ConfigFile
  def self.content
    return <<-EOF
default local

label local
localboot 0
EOF
  end


  def initialize node, debug_options
    @node = node
    @debug_options = debug_options
  end


  ##########################################################################
  private
  ##########################################################################


  def content
    self.class.content
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

