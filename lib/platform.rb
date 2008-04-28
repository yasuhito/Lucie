#
# All platform dependent operations should be defined here.
#


require 'rbconfig'


module Platform
  def family
    target_os = Config::CONFIG[ 'target_os' ] or raise 'Cannot determine operating system'
    case target_os
    when /darwin/
      'powerpc-darwin'
    when /32/
      'mswin32'
    when /cyg/
      'cygwin'
    when /solaris/
      'solaris'
    when /freebsd/
      'freebsd'
    when /linux/
      'linux'
    when /solaris/
      'solaris'
    else
      raise "Unknown OS: #{ target_os }"
    end
  end
  module_function :family


  def user
    family == 'mswin32' ? ENV[ 'USERNAME' ] : ENV[ 'USER' ]
  end
  module_function :user


  def prompt dir = Dir.pwd
    prompt = "#{ dir.gsub(/\//, File::SEPARATOR) } #{ user }$"
  end
  module_function :prompt


  def interpreter
    Config::CONFIG[ 'ruby_install_name' ]
  end
  module_function :interpreter
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
