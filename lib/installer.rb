require "build"
require "first-stage"
require "installers"
require "lucie/server"
require "lucie/utils"
require "nfsroot"


class Installer
  include Lucie::Utils


  DEFAULT_PACKAGE_REPOSITORY = "http://cdn.debian.or.jp/debian"
  STEPS = [ "Reboot", "Disk Partition", "Base System", "Kernel", "GRUB", "Misc", "SSH", "Reboot", "Configure", "OK" ]


  attr_accessor :http_proxy
  attr_accessor :installer_linux_image
  attr_accessor :package_repository
  attr_accessor :suite
  attr_reader :ip_address


  def self.path name
    File.join Installers.path, name
  end


  def self.config name
    File.join path( name ), "config.rb"
  end


  def self.read name
    unless File.directory?( path( name ) )
      return nil
    end
    eval IO.read( config( name ) )
  end


  def self.configure &block
    installer = Installer.new
    block.call installer
    installer.configure_nfsroot
    installer
  end


  def initialize
    @http_proxy = nil
    @package_repository = DEFAULT_PACKAGE_REPOSITORY
    @arch = Lucie::Server.architecture
    @suite = "lenny"
  end


  def name
    "#{ @suite }_#{ @arch }"
  end


  def path
    File.join Installers.path, name
  end


  def configure_nfsroot
    Nfsroot.configure do | nfsroot |
      nfsroot.http_proxy = @http_proxy
      nfsroot.kernel_package = @installer_linux_image if @installer_linux_image
      nfsroot.package_repository = @package_repository
      nfsroot.suite = @suite
      nfsroot.target_directory = File.join( path, "nfsroot" )
      nfsroot.verbose = ( ENV[ "VERBOSE" ] == "true" ? true : false )
    end
  end


  ##############################################################################
  # add/remove
  ##############################################################################


  def save options, messenger
    mkdir_p path, options.merge( :messenger => messenger )
    generate_config options, messenger
  end


  def kernel
    File.join path, "nfsroot/boot/vmlinuz-*"
  end


  def build lucie_server_ip_address, options, messenger
    @ip_address = lucie_server_ip_address
    Build.new( self, path, options, messenger ).run
  end


  def start node, linux_image, storage_conf, ldb_directory, logger, html_logger, options, messenger
    ( messenger || $stdout ).puts "node #{ node.name } is going to be installed using #{ storage_conf }"
    FirstStage.new( node, linux_image, storage_conf, ldb_directory, logger, html_logger, options, messenger ).run
  end


  ##############################################################################
  private
  ##############################################################################


  def generate_config options, messenger
    write_file Installer.config( name ), <<-CONFIG, options, messenger
Installer.configure do | installer |

  # HTTP proxy url.
  installer.http_proxy = #{ @http_proxy ? "'#{ @http_proxy }'" : 'nil' }

  # Package repository url.
  installer.package_repository = #{ @package_repository ? "'#{ @package_repository }'" : 'nil' }

  # Code name of debian version.
  installer.suite = #{ @suite ? "'#{ @suite }'" : 'nil' }

  installer.installer_linux_image = #{ @installer_linux_image ? "'#{ @installer_linux_image }'" : 'nil' }
end
CONFIG
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
