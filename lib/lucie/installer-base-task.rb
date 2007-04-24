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
begin
  require 'rake/classic_namespace'
rescue LoadError
  # This is ok, do nothing.
end
require 'rake/tasklib'


module Rake
  class InstallerBaseTask < TaskLib
    include Debootstrap


    INSTALLER_BASE_DIR = '/var/lib/lucie/installer_base'.freeze
    MIRROR_URI = 'http://www.debian.or.jp/debian/'.freeze


    attr_accessor :distribution
    attr_accessor :http_proxy
    attr_accessor :include
    attr_accessor :logger
    attr_accessor :mirror
    attr_accessor :name
    attr_accessor :suite
    attr_accessor :target_directory


    def self.load_aptget aptget # :nodoc:
      @@aptget = aptget
    end


    def self.load_debootstrap debootstrap # :nodoc:
      Debootstrap.load_debootstrap debootstrap
      @@debootstrap = debootstrap
    end


    def self.load_shell shell_class # :nodoc:
      Kernel.load_shell shell_class
    end


    def self.reset # :nodoc:
      load_aptget AptGet
      load_debootstrap Popen3::Debootstrap
      load_shell Popen3::Shell
    end


    reset


    def initialize name = :installer_base # :yield: self
      @logger = Lucie
      @http_proxy = nil
      @mirror = MIRROR_URI
      @name = name
      @target_directory = INSTALLER_BASE_DIR
      yield self if block_given?
      define_tasks
    end


    def installer_base_target
      return target( target_fname( @distribution, @suite ) )
    end
    alias :tgz :installer_base_target


    private


    def task_name key
      return {
        :build => @name,
        :tgz => installer_base_target,
        :rebuild => paste( 're', @name ),
        :clobber => paste( 'clobber_', @name )
      }[ key ]
    end


    def target path
      return File.join( @target_directory, path )
    end


    def define_tasks
      define_task_build
      define_task_rebuild
      define_task_clobber
      define_task_tgz

      # define task dependencies.
      task task_name( :build ) => [ task_name( :tgz ) ]
      task task_name( :rebuild ) => [ task_name( :clobber ), task_name( :build ) ]
    end


    def define_task_build
      desc "Build installer base tarball for #{ @distribution } distribution, version = ``#{ @suite }''."
      task task_name( :build )
    end


    def define_task_rebuild
      desc 'Force a rebuild of the installer base tarball.'
      task task_name( :rebuild )
    end


    def define_task_clobber
      desc "Remove #{ @target_directory }"
      task task_name( :clobber ) do
        sh_exec 'rm', '-rf', @target_directory
      end
    end


    def define_task_tgz
      file task_name( :tgz ) do
        @logger.info "Creating base system using debootstrap version #{ @@debootstrap.VERSION }"
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

        @@aptget.clean :root => @target_directory, :logger => @logger

        sh_exec 'rm', '-f', target( '/etc/resolv.conf' )
        build_installer_base_tarball
      end
    end


    def build_installer_base_tarball
      @logger.info "Creating installer base tarball on #{ installer_base_target }."
      sh_exec 'tar', '--one-file-system', '--directory', @target_directory, '--exclude', target_fname( @distribution, @suite ), '-czvf', installer_base_target, '.'
    end


    def target_fname distribution, suite
      return distribution + '_' + suite + '.tgz'
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
