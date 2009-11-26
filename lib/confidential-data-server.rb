require "lucie/debug"
require "lucie/utils"
require "socket"
require "tempfile"


class ConfidentialDataServer
  include Lucie::Debug
  include Lucie::Utils


  PORT = 58243


  def initialize encrypted, password, debug_options = {}
    @decrypted = decrypt( encrypted, password )
    @debug_options = debug_options
  end


  def start
    return if @debug_options[ :dry_run ]
    @server = TCPServer.open( "localhost", PORT )
    debug "Confidential data server started on port = #{ PORT }"
    main_loop
  end


  ##############################################################################
  private
  ##############################################################################


  def main_loop
    Kernel.loop do
      accept_and_reply
    end
  end


  def accept_and_reply
    Thread.start( @server.accept ) do | client |
      reply_to client
      client.close
    end
  end


  def reply_to client
    client.print @decrypted
  end


  def decrypt path, password
    decrypted = `openssl enc -pass pass:'#{ password }' -d -aes256 < #{ tempfile( IO.read( path ) ).path }`
    raise "Failed to decrypt #{ path }." if $?.to_i != 0
    decrypted
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
