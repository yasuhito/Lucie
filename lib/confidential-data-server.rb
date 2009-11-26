require "lucie/debug"
require "socket"
require "tempfile"


class ConfidentialDataServer
  include Lucie::Debug


  def initialize encrypted, password, debug_options = {}
    @decrypted = decrypt( encrypted, password )
    @debug_options = debug_options
  end


  def start
    return if @debug_options[ :dry_run ]
    @server = TCPServer.open( "localhost", port )
    debug "Confidential data server started on port = #{ port }"
    main_loop
  end


  ##############################################################################
  private
  ##############################################################################


  def port
    58243
  end


  def main_loop
    Kernel.loop do
      Thread.start( @server.accept ) do | client |
        connected client
      end
    end
  end


  def connected client
    client.print @decrypted
    client.close
  end


  def decrypt path, password
    decrypted = `openssl enc -pass pass:'#{ password }' -d -aes256 < #{ new_temp_file( IO.read( path ) ).path }`
    raise "Failed to decrypt #{ path }." if $?.to_i != 0
    decrypted
  end


  def new_temp_file contents
    temp = Tempfile.new( "confidential-data-server" )
    temp.print contents
    temp.flush
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
