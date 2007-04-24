#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'popen3/shell'


module Popen3
  class Apt
    def self.load_shell shell # :nodoc:
      @@shell = shell
    end


    def self.reset
      @@shell = Shell
    end


    reset


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
      @logger = nil
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
      return unless option
      if option[ :logger ]
        @logger = option[ :logger ]
      end
      if option[ :root ]
        @root = option[ :root ]
      end
      if option[ :env ]
        @env.merge! option[ :env ]
      end
    end


    def exec_shell
      if @root
        command_line = [ @env, 'chroot', @root, 'apt-get' ] + @command
      else
        command_line = [ @env, 'apt-get' ] + @command
      end

      @shell = @@shell.open do | shell |
        shell.on_stdout do | line |
          if @logger
            @logger.debug line
          end
        end
        shell.on_stderr do | line |
          if @logger
            @logger.error line
          end
        end
        shell.exec( *command_line )
      end
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
### indent-tabs-mode: nil
### End:
