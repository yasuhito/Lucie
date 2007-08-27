#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'popen3/shell'


module Popen3
  class Apt
    def self.get command, option = nil
      self.new command.split( ' ' ), option
    end


    def self.clean option = nil
      self.new :clean, option
    end


    def self.update option = nil
      self.new :update, option
    end


    def self.check option = nil
      self.new :check, option
    end


    def initialize command, option = nil
      @root = nil
      @env = { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }
      case command
      when String, Symbol
        @command = [ command.to_s ]
      when Array
        @command = command
      end
      set_option option
      exec_shell
    end


    def child_status
      return @shell.child_status
    end


    private


    def set_option option
      unless option
        return
      end

      if option[ :root ]
        @root = option[ :root ]
      end
      if option[ :env ]
        @env.merge! option[ :env ]
      end
    end


    def exec_shell
      @shell = Shell.open do | shell |
        shell.on_stdout do | line |
          Lucie::Log.debug line
        end
        shell.on_stderr do | line |
          Lucie::Log.debug line
        end

        shell.on_failure do
          raise "#{ command_line_string } failed!"
        end

        shell.exec( @env, *command_line )
      end
    end


    def chroot_command
      if @root
        return [ 'chroot', @root ]
      end
      return []
    end


    def command_line
      return chroot_command + [ 'apt-get' ] + @command
    end


    def command_line_string
      env_string = []
      @env.each do | key, value |
        env_string << "'#{ key }' => '#{ value }'"
      end
      return "ENV{ #{ env_string.join( ', ' ) } }, '#{ command_line.join( ' ' ) }'"
    end
  end
end


module AptGet
  def apt command, option
    return Popen3::Apt.new( command, option )
  end
  module_function :apt


  def clean option = nil
    return apt( :clean, option )
  end
  module_function :clean


  def check option = nil
    return apt( :check, option )
  end
  module_function :check


  def update option = nil
    return apt( :update, option )
  end
  module_function :update
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
