require 'lucie/log'
require 'popen3/shell'


class Apt
  def initialize options, messenger
    @options = options
    @messenger = messenger
    @env = { "LC_ALL" => "C", "DEBIAN_FRONTEND" => "noninteractive", "DEBCONF_NONINTERACTIVE_SEEN" => "true", "DEBCONF_USE_CDEBCONF" => "true" }
  end


  def get command
    case command
    when Array
      exec_shell command
    when String
      exec_shell command.split( ' ' )
    end
  end


  def clean
    exec_shell 'clean'
  end


  def update
    exec_shell 'update'
  end


  def check
    exec_shell 'check'
  end


  ############################################################################
  private
  ############################################################################


  def exec_shell command
    env = ( @options[ :env ] ? ( @env.merge @options[ :env ] ) : @env )
    env.each do | key, value |
      ENV[ key ] = value
    end
    ( @messenger || $stderr ).puts command_line( command ) if @options[ :dry_run ] or @options[ :verbose ]
    system command_line( command ) unless @options[ :dry_run ]
  end


  def chroot_command
    if @options[ :root ]
      return "sudo chroot #{ @options[ :root ] }"
    end
    return nil
  end


  def command_line command
    [ chroot_command, "apt-get", "--yes", "--fix-broken", "--force-yes", '-o Dpkg::Options::="--force-confdef"', '-o Dpkg::Options::="--force-confold"', command ].join( ' ' )
  end


  def command_line_string command
    env_string = []
    @env.each do | key, value |
      env_string << "'#{ key }' => '#{ value }'"
    end
    return "ENV{ #{ env_string.join( ', ' ) } }, '#{ command_line( command ) }'"
  end
end


module AptGet
  def apt command, options = nil, messenger = nil
    Apt.new( options, messenger ).get( command )
  end
  module_function :apt


  def clean options = nil, messenger = nil
    Apt.new( options, messenger ).clean
  end
  module_function :clean


  def check options = nil, messenger = nil
    Apt.new( options, messenger ).check
  end
  module_function :check


  def update options = nil, messenger = nil
    Apt.new( options, messenger ).update 
  end
  module_function :update
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
