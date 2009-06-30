require "lucie"


class Configuration
  @installers_directory = File.join( Lucie::ROOT, "installers" )
  @installers_temporary_directory = File.join( Lucie::ROOT, "tmp", "installers" )
  @log_directory = File.join( Lucie::ROOT, "log" )
  @temporary_directory = File.join( Lucie::ROOT, "tmp" )
  @tftp_root = "/var/lib/tftpboot"


  class << self
    attr_accessor :installers_directory
    attr_accessor :installers_temporary_directory
    attr_accessor :log_directory
    attr_accessor :temporary_directory
    attr_accessor :tftp_root
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
