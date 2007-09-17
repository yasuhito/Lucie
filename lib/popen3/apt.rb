require 'popen3/shell'


module Popen3
  class Apt
    def self.get command, option = nil
      self.new( option ).get command
    end


    def self.clean option = nil
      self.new( option ).clean
    end


    def self.update option = nil
      self.new( option ).update
    end


    def self.check option = nil
      self.new( option ).check
    end


    def initialize option = nil
      @root = nil
      @env = { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }
      set_option option
    end


    def get command
      exec_shell command.split( ' ' )
    end


    def clean
      exec_shell [ 'clean' ]
    end


    def update
      exec_shell [ 'update' ]
    end


    def check
      exec_shell [ 'check' ]
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


    def exec_shell command
      @shell = Shell.open do | shell |
        shell.on_stdout do | line |
          Lucie::Log.debug line
        end
        shell.on_stderr do | line |
          Lucie::Log.debug line
        end

        shell.on_failure do
          raise "#{ command_line_string( command ) } failed!"
        end

        shell.exec( @env, *command_line( command ) )
      end
    end


    def chroot_command
      if @root
        return [ 'chroot', @root ]
      end
      return []
    end


    def command_line command
      return chroot_command + [ 'apt-get' ] + command
    end


    def command_line_string command
      env_string = []
      @env.each do | key, value |
        env_string << "'#{ key }' => '#{ value }'"
      end
      return "ENV{ #{ env_string.join( ', ' ) } }, '#{ command_line( command ).join( ' ' ) }'"
    end
  end
end


module AptGet
  def apt command, option
    return Popen3::Apt.get( command, option )
  end
  module_function :apt


  def clean option = nil
    return Popen3::Apt.clean( option )
  end
  module_function :clean


  def check option = nil
    return Popen3::Apt.check( option )
  end
  module_function :check


  def update option = nil
    return Popen3::Apt.update( option )
  end
  module_function :update
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
