require "rubygems"

require "apt"
require "configuration"
require "debootstrap"
require "lucie/log"
require "lucie/shell"
require "rake"
require "rake/tasklib"


class NfsrootBase < Rake::TaskLib
  attr_accessor :arch
  attr_accessor :exclude
  attr_accessor :http_proxy
  attr_accessor :include
  attr_accessor :package_repository
  attr_accessor :suite

  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.configure &block
    self.new( &block )
  end


  def target
    File.join Configuration.installers_temporary_directory, tgz
  end


  ##############################################################################
  private
  ##############################################################################


  def initialize # :nodoc:
    set_defaults
    yield self
    define_tasks
    define_task_dependencies
  end


  def set_defaults
    @arch = `dpkg --print-architecture`.chomp
    @suite = "lenny"
  end


  # Task definitions ###########################################################


  def define_tasks
    define_task_build
    define_task_tgz
  end


  def define_task_build
    desc "Build installer base tarball for Debian #{ @suite }."
    task "installer:nfsroot_base"
  end
  

  def define_task_tgz
    file target do
      info "Creating base system"
      call_debootstrap
      clean_old_debs
      remove_host_dependent_files
      build_base_tarball
    end
  end


  def define_task_dependencies
    task "installer:nfsroot_base" => target
  end


  # debootstrap ################################################################


  def call_debootstrap
    Debootstrap.setup do | d |
      d.arch = @arch
      d.exclude = [ "dhcp-client", "info", "udev" ] + ( @exclude ? @exclude : [] )
      d.http_proxy = @http_proxy
      d.include = @include ? @include : []
      d.package_repository = @package_repository
      d.suite = @suite
      d.target = temporary_directory

      d.verbose = @verbose
      d.dry_run = @dry_run
      d.messenger = @messenger
    end
  end


  # Paths ######################################################################


  def tgz
    "#{ @suite }_#{ @arch }.tgz"
  end


  def tgz_directory
    File.dirname target
  end


  def debootstrap path
    File.join temporary_directory, path
  end


  def temporary_directory
    File.join Configuration.temporary_directory, "debootstrap"
  end


  # Helpers ####################################################################


  def clean_old_debs
    AptGet.clean( { :root => temporary_directory, :verbose => @verbose, :dry_run => @dry_run }, @messenger )
  end


  def remove_host_dependent_files
    run "rm -f #{ debootstrap( '/etc/resolv.conf' ) }"
    run "rm -f #{ debootstrap( '/etc/udev/rules.d/z25_persistent-net.rules' ) }"
  end


  def build_base_tarball
    info "Creating installer base tarball on #{ target }"
    run "mkdir -p #{ tgz_directory }"
    run "tar --one-file-system --directory #{ temporary_directory } --exclude #{ tgz } -czf #{ target } ."
  end

  
  def info msg
    Lucie::Log.info msg
    ( @messenger || $stdout ).puts msg
  end


  def run command
    Lucie::Log.debug command
    ( @messenger || $stderr ).puts command if @verbose
    sh_exec command unless @dry_run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
