#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class Installers
  def self.load_all
    Installers.new( Configuration.installers_directory ).load_all
  end


  def self.load_installer dir
    installer = Installer.read( dir, load_config = false )
    installer.path = dir
    return installer
  end


  def initialize dir = Configuration.installers_directory
    @dir = dir
    @list = []
  end


  def load_all
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      Installers.load_installer child
    end
    return self
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
