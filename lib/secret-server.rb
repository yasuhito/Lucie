require "socket"
require "tempfile"


class SecretServer
  def initialize encrypted, password, options = {}
    @decrypted = decrypt( IO.read( encrypted ), password )
    @options = options
  end


  def start
    return if @options[ :dry_run ]
    @server = TCPServer.open( 58243 )
    main_loop
  end


  def connected client
    client.puts @decrypted
    client.close
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


  def decrypt encrypted, password
    `openssl enc -pass pass:#{ password } -d -aes256 < #{ new_temp_file( encrypted ).path }`
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
