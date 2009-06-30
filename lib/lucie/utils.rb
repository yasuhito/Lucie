require "lucie/log"
require "lucie/shell"
require "tempfile"


module Lucie
  module Utils
    module_function


    def rm_f target, options = {}, messenger = nil
      debug_print "rm -f #{ target }", options, messenger
      FileUtils.rm_f target, :noop => options[ :dry_run ]
    end


    def touch target, options = {}, messenger = nil
      debug_print "touch #{ target }", options, messenger
      FileUtils.touch target, :noop => options[ :dry_run ]
    end


    def mkdir_p target, options = {}, messenger = nil
      debug_print "mkdir -p #{ target }", options, messenger
      FileUtils.mkdir_p target, :noop => options[ :dry_run ]
    end


    def ln_s source, dest, options = {}, messenger = nil
      debug_print "ln -s #{ source } #{ dest }", options, messenger
      FileUtils.ln_s source, dest, :noop => options[ :dry_run ]
    end


    def run command, options = {}, messenger = nil
      debug_print command, options, messenger
      Lucie::Shell.new( options, messenger ).run command
    end


    def write_file path, body, options = {}, messenger = nil
      write_temp_and_copy( path, body, options[ :sudo ] ) unless options[ :dry_run ]
      debug_print_write_file path, body, options, messenger
    end


    ############################################################################
    private
    module_function
    ############################################################################


    def debug_print command, options, messenger
      Lucie::Log.verbose = options[ :verbose ] || options[ :dry_run ]
      Lucie::Log.debug command
      ( messenger || $stderr ).puts( command ) if options[ :dry_run ] || options[ :verbose ]
    end


    def debug_print_write_file path, body, options, messenger
      debug_print "file write (#{ path })", options, messenger
      body.split( "\n" ).each do | each |
        debug_print "> #{ each }", options, messenger
      end
    end


    def write_temp_and_copy path, body, sudo = false
      sudo_cmd = sudo ? "sudo " : ""
      tempfile body do | tmp |
        run "#{ sudo_cmd }cp #{ tmp.path } #{ path }", :verbose => false, :dry_run => false
        run "#{ sudo_cmd }chmod 644 #{ path }", :verbose => false, :dry_run => false
      end
    end


    def tempfile body
      tmp = Tempfile.new( "lucie" )
      tmp.print body
      tmp.flush
      yield tmp
      tmp.close
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
