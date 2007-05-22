#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'lucie/log'
require 'popen3/shell'


module Popen3
  class Debootstrap
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


    def self.VERSION
      version = nil
      Shell.open do | shell |
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

      @shell = Shell.open do | shell |
        Thread.new do
          loop do
            shell.puts
          end
        end

        shell.on_stdout do | line |
          Lucie::Log.debug line
        end

        shell.on_stderr do | line |
          case line
          when /\Aln: \S+ File exists/
            raise RuntimeError, line
          end
          Lucie::Log.error line
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
  def debootstrap &block
    Popen3::Debootstrap.new( &block )
  end
  module_function :debootstrap
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
