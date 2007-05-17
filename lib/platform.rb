#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'rbconfig'


module Platform
  def family
    target_os = Config::CONFIG["target_os"] or raise 'Cannot determine operating system'
    case target_os
    when /darwin/ then 'powerpc-darwin'
    when /32/ then 'mswin32'
    when /cyg/ then 'cygwin'
    when /solaris/ then 'solaris'
    when /freebsd/ then 'freebsd'
    when /linux/ then 'linux'
    when /solaris/ then 'solaris'
    else raise "Unknown OS: #{target_os}"
    end
  end
  module_function :family


  def user
    family == "mswin32" ? ENV['USERNAME'] : ENV['USER']
  end
  module_function :user


  def prompt(dir=Dir.pwd)
    prompt = "#{dir.gsub(/\//, File::SEPARATOR)} #{user}$"
  end
  module_function :prompt
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
