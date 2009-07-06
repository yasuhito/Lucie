require "socket"
require "tempfile"


class SecretServer
  def initialize encrypted, password, options = {}
    @decrypted = decrypt( encrypted, password )
    @options = options
  end


  def start
    return if @options[ :dry_run ]
    @server = TCPServer.open( "localhost", 58243 )
    main_loop
  end


  ##############################################################################
  private
  ##############################################################################


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


  def decrypt encrypted, password
    decrypted = `openssl enc -pass pass:'#{ password }' -d -aes256 < #{ new_temp_file( IO.read( encrypted ) ).path }`
    raise "Failed to decrypt #{ encrypted }." if $?.to_i != 0
    decrypted
  end


  def new_temp_file contents
    temp = Tempfile.new( "secret-server" )
    temp.print contents
    temp.flush
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
