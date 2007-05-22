#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


module Lucie
  class StderrLogger
    def self.method_missing method, *args, &block
      STDERR.puts args.join( ' ' )
    end
  end


  class Log
    def self.verbose= verbose
      @verbose = verbose
    end

    
    def self.verbose?
      @verbose or false
    end

  
    def self.event description, severity = :info
      if severity == :debug and not @verbose
        return
      end
      message = "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{description}"
      Log.send severity.to_sym, message
    end


    def self.mylogger
      unless const_defined?( :RAILS_DEFAULT_LOGGER )
        return StderrLogger
      else
        return RAILS_DEFAULT_LOGGER
      end
    end


    def self.method_missing method, *args, &block
      if method == :debug and not @verbose
        return
      end

      first_arg = args.shift
      message = backtrace = nil
      case first_arg
      when Exception
        message = "#{ print_severity( method ) } #{ first_arg.message }"
        backtrace = first_arg.backtrace.map { |line| "#{print_severity(method)}   #{line}" }
      else
        message = "#{ print_severity( method ) } #{ first_arg }"
      end

      mylogger.send method, message, *args, &block

      if backtrace and not defined?( Test )
        backtrace.each do | line |
          mylogger.send method, line
        end
      end
#       is_error = (method == :error or method == :fatal)
#       if @verbose or is_error and defined?( RAILS_ENV ) and RAILS_ENV != 'test'
#         stream = is_error ? STDERR : STDOUT
#         stream.puts message
#         backtrace.each { |line| stream.puts line } if backtrace and @verbose
#       end
    end

    
    # nicely aligned printout of message severity
    def self.print_severity severity
      severity = severity.to_s
      '[' + severity + ']' + ' ' * ( 5 - severity.length )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
