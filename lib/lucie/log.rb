module Lucie
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
      message = "[#{ Time.now.strftime( '%Y-%m-%d %H:%M:%S' ) }] #{ description }"
      Log.send severity.to_sym, message
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
        backtrace = first_arg.backtrace.map do | line |
          "#{ print_severity( method ) }   #{ line }"
        end
      else
        message = "#{ print_severity( method ) } #{ first_arg }"
      end

      if defined?( RAILS_DEFAULT_LOGGER )
        RAILS_DEFAULT_LOGGER.send method, message, *args, &block

        if backtrace
          backtrace.each do | line |
            RAILS_DEFAULT_LOGGER.send method, line
          end
        end
      end

      is_error = ( method == :error or method == :fatal )
      if @verbose or is_error
        stream = is_error ? STDERR : STDOUT
        stream.puts message
        if backtrace and @verbose
          backtrace.each do | line |
            stream.puts line
          end
        end
      end
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
