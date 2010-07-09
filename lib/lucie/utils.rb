require "lucie/logger/utils"
require "lucie/shell"
require "tempfile"


module Lucie
  module Utils
    module_function


    #
    # Remove a file specified in +path+. This method cannot remove
    # directories. Command-line is logged with Lucie::Log.
    #
    # Options: verbose dry_run
    #
    #  Lucie::Utils.rm_f "junk.txt"
    #  Lucie::Utils.rm_f "dust.txt", :verbose => true
    #  Lucie::Utils.rm_f "memo.txt", :dry_run => true
    #
    def rm_f path, options = {}
      debug_print "rm -f #{ path }", options
      FileUtils.rm_f path, :noop => options[ :dry_run ]
    end


    #
    # Updates modification time (mtime) and access time (atime) of the
    # file specified in +path+. The file is created if it doesn't
    # exist. Command-line is logged with Lucie::Log.
    #
    # Options: verbose dry_run
    #
    #  Lucie::Utils.touch "timestamp"
    #  Lucie::Utils.touch "OK", :verbose => true
    #  Lucie::Utils.touch "OK", :dry_run => true
    #
    def touch path, options = {}
      debug_print "touch #{ path }", options
      FileUtils.touch path, :noop => options[ :dry_run ]
    end


    #
    # Creates a directory and all its parent directories. For example,
    #
    #   Lucie::Utils.mkdir_p "/usr/local/lib/ruby"
    #
    # causes to make following directories, if it does not exist.
    #
    #  * /usr
    #  * /usr/local
    #  * /usr/local/lib
    #  * /usr/local/lib/ruby
    #
    # Command-line is logged with Lucie::Log.
    #
    # Options: verbose dry_run
    #
    def mkdir_p directory, options = {}
      debug_print "mkdir -p #{ directory }", options
      FileUtils.mkdir_p directory, :noop => options[ :dry_run ]
    end


    #
    # Creates a symbolic link +dest+ which points to +source+. If
    # +dest+ already exists and it is a directory, creates a symbolic
    # link +dest/source+. If +dest+ already exists and it is not a
    # directory, raises Errno::EEXIST. Command-line is logged with
    # Lucie::Log.
    #
    # Options: verbose dry_run
    #
    #  Lucie::Utils.ln_s "/usr/bin/gcc-3.0", "/usr/bin/gcc"
    #  Lucie::Utils.ln_s "/usr/bin/gcc-3.0", "/usr/bin/gcc", :verbose => true
    #  Lucie::Utils.ln_s "/usr/bin/gcc-3.0", "/usr/bin/gcc", :dry_run => true
    #
    def ln_s source, dest, options = {}
      debug_print "ln -s #{ source } #{ dest }", options
      FileUtils.ln_s source, dest, :noop => options[ :dry_run ]
    end


    #
    # Spawns a new process specified with +command+. If multiple lines
    # are passed as +command+, empty lines and comments (starting with
    # '#') are ignored. Command-line is logged with Lucie::Log.
    #
    # Options: verbose dry_run
    #
    #  Lucie::Utils.run "ls", :verbose => true
    #  Lucie::Utils.run <<-COMMAND
    #  # create yasuhito's home directory
    #  mkdir /home/yasuhito
    #  chown yasuhito:yasuhito /home/yasuhito
    #  COMMAND
    #
    def run command, options = {}
      command.split( "\n" ).each do | each |
        next if /^#/=~ each
        next if /^\s*$/=~ each
        Lucie::Shell.new( options ).run each
      end
    end


    #
    # Spawns a new process specified with +command+ using +sudo+. If
    # multiple lines are passed as +command+, empty lines and comments
    # (starting with '#') are ignored. Command-line is logged with
    # Lucie::Log.
    #
    # Options: verbose dry_run
    #
    #  Lucie::Utils.sudo_run "cat /var/log/syslog", :verbose => true
    #  Lucie::Utils.sudo_run <<-COMMAND
    #  # Remove the tftp entry from inetd
    #  /usr/sbin/update-inetd --disable tftp
    #  # To reflect above change, send a signal to inetd.
    #  kill -HUP `cat /var/run/inetd.pid`
    #  COMMAND
    #
    def sudo_run command, options = {}
      run "sudo #{ command }", options
    end


    #
    # Creates a new file +path+ with contents +body+. If +sudo+ option
    # is specified, the file creation is done with root
    # priviledge. Information is logged with Lucie::Log.
    #
    # Options: verbose dry_run sudo
    #
    #  Lucie::Utils.write_file "/tmp/hello.txt", "Hello World"
    #  Lucie::Utils.write_file "/root/memo.txt", "Secret File", :sudo => true
    #
    def write_file path, body, options = {}
      write_temp_and_copy( path, body, options[ :sudo ] ? "sudo" : nil ) unless options[ :dry_run ]
      debug_print_write_file path, body, options
    end


    #
    # Creates a temporary file of mode 0600 in the temporary directory
    # with contents +body+, opens it with mode "w+", and returns a
    # Tempfile object which represents the created temporary file. A
    # Tempfile object can be treated just like a normal File object.
    #
    def tempfile body
      tmp = Tempfile.new( "lucie" )
      tmp.print body
      tmp.close
      tmp
    end


    def permission_of file
      File.stat( file ).mode.to_s( 8 )[ -4, 4 ]
    end


    ############################################################################
    private
    ############################################################################


    def debug_print message, options
      Lucie::Logger::Utils.new( options ).debug message
    end
    module_function :debug_print


    def debug_print_write_file path, body, options
      debug_print "file write (#{ path })", options
      body.split( "\n" ).each do | each |
        debug_print "> #{ each }", options
      end
    end
    module_function :debug_print_write_file


    def write_temp_and_copy path, body, sudo
      run "#{ sudo } cp #{ tempfile( body ).path } #{ path }".strip
      run "#{ sudo } chmod 644 #{ path }".strip
    end
    module_function :write_temp_and_copy
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
