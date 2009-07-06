require "socket"
require "tempfile"


class SecretServer
  def initialize encrypted, password, options = {}
    @decrypted = decrypt( encrypted, password )
    @options = options
  end


  def start
    @server = TCPServer.open( 58243 )
    return if @options[ :dry_run ]
    Kernel.loop do
      Thread.start( @server.accept ) do | client |
        connected client
      end
    end
  end


  def connected client
    client.puts @decrypted
    client.close
  end


  ##############################################################################
  private
  ##############################################################################


  def decrypt encrypted, password
    temp = Tempfile.new( "secret-server" )
    temp.print encrypted
    temp.flush
    `openssl enc -pass pass:#{ password } -d -aes256 < #{ temp.path }`
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
