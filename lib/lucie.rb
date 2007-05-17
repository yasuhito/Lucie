#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'logger'


module Lucie
  PINK = { :console => "[0;31m", :html => "FFA0A0" }
  GREEN = { :console => "[0;32m", :html => "00CD00" }
  YELLOW = { :console => "[0;33m", :html => "FFFF60" }
  SLATE = { :console => "[0;34m", :html => "80A0FF" }
  ORANGE = { :console => "[0;35m", :html => "FFA500" }
  BLUE = { :console => "[0;36m", :html => "40FFFF" }
  RESET = { :console => "[0m", :html => "" }


  @@colormap = {
    :fatal => PINK,
    :error => YELLOW,
    :warn => ORANGE,
    :info => GREEN,
    :debug => SLATE
  }


  ##############################################################################
  # Unit test helper methods
  ##############################################################################


  def load_io io # :nodoc:
    @@io = io
  end
  module_function :load_io


  def reset # :nodoc:
    load_io $stderr
    @@logging_level = :info
  end
  module_function :reset


  reset


  ##############################################################################
  # Logging
  ##############################################################################


  def console_color level, str # :nodoc:
    @@colormap[ level ][ :console ] + str + RESET[ :console ]
  end
  module_function :console_color


  def do_log? messageType # :nodoc:
    levels = { :fatal => 5, :error => 4, :warn => 3, :info => 2, :debug => 1 }
    return( levels[ messageType ] >= levels[ @@logging_level ] )
  end
  module_function :do_log?


  def logging_level= level
    @@logging_level = level
  end
  module_function :logging_level=


  def fatal message
    if do_log?( :fatal )
      @@io.puts console_color( :fatal, "%s: %s" % [ :fatal, message ] )
    end
  end
  module_function :fatal


  def error message
    if do_log?( :error )
      @@io.puts console_color( :error, "%s: %s" % [ :error, message ] )
    end
  end
  module_function :error


  def warn message
    if do_log?( :warn )
      @@io.puts console_color( :warn, "%s: %s" % [ :warn, message ] )
    end
  end
  module_function :warn


  def info message
    if do_log?( :info )
      @@io.puts console_color( :info, "%s: %s" % [ :info, message ] )
    end
  end
  module_function :info


  def debug message
    if do_log?( :debug )
      @@io.puts console_color( :debug, "%s: %s" % [ :debug, message ] )
    end
  end
  module_function :debug


  ##############################################################################
  # Utility methods
  ##############################################################################


  def env_lc_all
    return { 'LC_ALL' => 'C' }
  end
  module_function :env_lc_all
end
