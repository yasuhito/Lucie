#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'lucie'
require 'popen3/apt'
require 'popen3/debootstrap'
require 'popen3/shell'
require 'rake'
require 'rake/tasklib'


class NfsrootBase < Rake::TaskLib
  include Debootstrap


  attr_accessor :distribution
  attr_accessor :http_proxy
  attr_accessor :include
  attr_accessor :logger
  attr_accessor :mirror
  attr_accessor :name
  attr_accessor :suite
  attr_accessor :target_directory


  def initialize name = :nfsroot_base # :yield: self
    @logger = Lucie
    @name = name
    yield self if block_given?
    define_tasks
  end


  def nfsroot_base_target
    return target( target_fname( @distribution, @suite ) )
  end
  alias :tgz :nfsroot_base_target


  private


  def target path
    return File.join( @target_directory, path )
  end


  def define_tasks
    define_task_build
    define_task_rebuild
    define_task_clobber
    define_task_tgz

    # define task dependencies.
    task paste( 'installer:', @name ) => [ nfsroot_base_target ]
    task paste( 'installer:re', @name ) => [ paste( 'installer:clobber_', @name ), paste( 'installer:', @name ) ]
  end


  def define_task_build
    namespace 'installer' do
      desc "Build installer base tarball for #{ @distribution } distribution, version = ``#{ @suite }''."
      task @name
    end
  end


  def define_task_rebuild
    namespace 'installer' do
      desc 'Force a rebuild of the installer base tarball.'
      task paste( 're', @name )
    end
  end


  def define_task_clobber
    desc "Remove #{ @target_directory }"
    namespace 'installer' do
      task paste( 'clobber_', @name ) do
        sh_exec 'rm', '-rf', @target_directory
      end
    end
  end


  def define_task_tgz
    file nfsroot_base_target do
      @logger.info "Creating base system using debootstrap version #{ Popen3::Debootstrap.VERSION }"
      @logger.info "Calling debootstrap #{ suite } #{ target_directory } #{ mirror }"

      debootstrap do | option |
        option.logger = @logger
        option.env = { 'LC_ALL' => 'C' }.merge( 'http_proxy' => @http_proxy )
        # [???] Exclude option is hard-coded. This should be read only for most of users?
        option.exclude = [ 'dhcp-client', 'info' ]
        option.suite = @suite
        option.target = @target_directory
        option.mirror = @mirror
        option.include = @include
      end

      AptGet.clean :root => @target_directory, :logger => @logger

      sh_exec 'rm', '-f', target( '/etc/resolv.conf' )
      build_nfsroot_base_tarball
    end
  end


  def build_nfsroot_base_tarball
    @logger.info "Creating installer base tarball on #{ nfsroot_base_target }."
    sh_exec 'tar', '--one-file-system', '--directory', @target_directory, '--exclude', target_fname( @distribution, @suite ), '-czvf', nfsroot_base_target, '.'
  end


  def target_fname distribution, suite
    return distribution + '_' + suite + '.tgz'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End: