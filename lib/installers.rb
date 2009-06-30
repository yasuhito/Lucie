require 'configuration'
require 'installer'


class Installers
  def self.path
    Configuration.installers_temporary_directory
  end


  def self.add installer, options, messenger
    self.new.__send__ :add, installer, options, messenger
  end


  def self.remove! name, options = {}, messenger = $stderr
    installer = find( name )
    installer.remove!( options, messenger ) if installer
  end


  def self.find name
    Installer.read name
  end


  def self.load_all
    self.new.__send__ :load_all
  end


  def self.size
    load_all.size
  end


  def self.sort
    load_all.sort_by do | each |
      each.suite
    end
  end


  def initialize
    load_all
  end


  ##############################################################################
  private
  ##############################################################################


  def load_all
    @list = installer_names.collect do | each |
      Installers.find each
    end
  end


  def add installer, options, messenger
    installer.save options, messenger
    @list << installer
  end


  def directories
    Dir[ "#{ Installers.path }/*" ].select do | each |
      File.directory? each
    end
  end


  def installer_names
    directories.collect do | each |
      File.basename each
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
