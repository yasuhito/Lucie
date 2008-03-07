#
# Rake task definitions for creating a base nfsroot tarball.
#


require 'popen3/apt'
require 'popen3/shell'
require 'rake'
require 'rake/tasklib'


# Defines 4 rake targets:
#
#  * RAILS_ROOT/installers/.base/DISTRIBUTION_SUITE_ARCH.tgz': builds debootstrap tarball
#  * installer:nfsroot_base: is an alias for the debootstrap tarball target.
#  * installer:clobber_nfsroot_base: clobbers temporary nfsroot directory.
#  * installer:rebuild_nfsroot_base: clobbers and rebuilds tarball
#
class NfsrootBase < Rake::TaskLib
  attr_accessor :arch
  attr_accessor :distribution
  attr_accessor :http_proxy
  attr_accessor :include
  attr_accessor :mirror
  attr_accessor :suite
  attr_accessor :target_directory


  def initialize
    @arch = 'i386'
    @distribution = 'debian'
    @name = :nfsroot_base
    @suite = 'etch'
    @target_directory = File.join( RAILS_ROOT, 'installers', '.base' )
  end


  def self.configure &block
    nfsroot_base = self.new
    block.call nfsroot_base
    nfsroot_base.define_tasks
    nfsroot_base
  end


  def nfsroot_base_target
    File.expand_path target( target_fname( @distribution, @suite, @arch ) )
  end
  alias :tgz :nfsroot_base_target


  def define_tasks
    define_task_build
    define_task_rebuild
    define_task_clobber
    define_task_tgz

    # define task dependencies.
    task paste( 'installer:', @name ) => [ nfsroot_base_target ]
    task paste( 'installer:rebuild_', @name ) => [ paste( 'installer:clobber_', @name ), paste( 'installer:', @name ) ]
  end


  ################################################################################
  private
  ################################################################################


  def define_task_build
    namespace 'installer' do
      desc "Build installer base tarball for #{ @distribution } distribution, version = ``#{ @suite }''."
      task @name
    end
  end


  def define_task_rebuild
    namespace 'installer' do
      desc 'Force a rebuild of the installer base tarball.'
      task paste( 'rebuild_', @name )
    end
  end


  def define_task_clobber
    desc "Remove #{ temporary_nfsroot_directory }"
    namespace 'installer' do
      task paste( 'clobber_', @name ) do
        sh_exec "rm -rf #{ temporary_nfsroot_directory }/*"
      end
    end
  end


  def define_task_tgz
    file nfsroot_base_target do
      STDOUT.puts "Creating base system using debootstrap version #{ Debootstrap.VERSION }"
      STDOUT.puts "Calling debootstrap #{ @suite } #{ temporary_nfsroot_directory } #{ @mirror }"

      Debootstrap.start do | option |
        option.env = { 'LC_ALL' => 'C' }.merge( 'http_proxy' => @http_proxy )
        option.arch = @arch
        option.exclude = [ 'dhcp-client', 'info' ]
        option.suite = @suite
        option.target = temporary_nfsroot_directory
        option.mirror = @mirror
        option.include = @include
      end

      AptGet.clean :root => temporary_nfsroot_directory

      sh_exec "rm -f #{ target( '/etc/resolv.conf' ) }"
      build_nfsroot_base_tarball
    end
  end


  def build_nfsroot_base_tarball
    STDOUT.puts "Creating installer base tarball on #{ nfsroot_base_target }."

    unless File.exists?( @target_directory )
      sh_exec "mkdir #{ @target_directory }"
    end
    sh_exec "tar --one-file-system --directory #{ temporary_nfsroot_directory } --exclude #{ target_fname( @distribution, @suite, @arch ) } -czf #{ nfsroot_base_target } ."
  end


  def target path
    File.join @target_directory, path
  end


  def target_fname distribution, suite, arch
    [ distribution, suite, arch ].join( '_' ) + '.tgz'
  end


  def temporary_nfsroot_directory
    File.join RAILS_ROOT, 'tmp', "debootstrap.#{ @arch }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
