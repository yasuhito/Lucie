#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'popen3/shell'


module Popen3
  class Debootstrap
    attr_accessor :logger


    class DebootstrapOption # :nodoc:
      attr_accessor :env
      attr_accessor :exclude
      attr_accessor :include
      attr_accessor :mirror
      attr_accessor :suite
      attr_accessor :target


      def commandline
        exclude = @exclude ? "--exclude=#{ @exclude.join( ',' ) }" : nil
        include = @include ? "--include=#{ @include.join( ',' ) }" : nil
        return [ '/usr/sbin/debootstrap', exclude, include, @suite, @target, @mirror ].compact
      end
    end


    def self.load_shell shell # :nodoc:
      @@shell = shell
    end


    def self.reset
      @@shell = Shell
    end


    reset


    def self.VERSION
      version = nil
      @@shell.open do | shell |
        shell.on_stdout do | line |
          # [XXX] raise an exception if version is not available.
          if /^ii\s+debootstrap\s+(\S+)/=~ line
            version = $1
          end
        end
        shell.exec( { 'LC_ALL' => 'C' }, 'dpkg', '-l' )
      end
      return version
    end


    def initialize
      @logger = nil
      @option = DebootstrapOption.new
      yield self
      exec_shell
    end


    def child_status
      return @shell.child_status
    end


    def method_missing message, *arg
      @option.__send__ message, *arg
    end


    private


    def exec_shell
      error_message = []

      @shell = @@shell.open do | shell |
        Thread.new do
          loop do
            shell.puts
          end
        end

        shell.on_stdout do | line |
          if @logger
            @logger.debug line
          end
        end

        shell.on_stderr do | line |
          case line
          when /\Aln: \S+ File exists/
            raise RuntimeError, line
          end
          if @logger
            @logger.error line
          end
          error_message.push line
        end

        shell.on_failure do
          raise RuntimeError, error_message.last
        end

        shell.exec @option.env, *@option.commandline
      end
    end
  end
end


# Abbrebiation
module Debootstrap
  def load_debootstrap debootstrap # :nodoc:
    @@debootstrap = debootstrap
  end
  module_function :load_debootstrap


  def reset # :nodoc:
    load_debootstrap Popen3::Debootstrap
  end
  module_function :reset


  self.reset


  def debootstrap &block
    @@debootstrap.new( &block )
  end
  module_function :debootstrap
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
