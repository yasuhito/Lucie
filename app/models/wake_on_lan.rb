class WakeOnLan
  def self.wake mac_address
    begin
      packed = mac_address.delete( '-:' ).to_a.pack( 'H12' )
      message = "\xff" * 6 + packed * 16
      socket = UDPSocket.open()
      socket.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1
      socket.send message, 0, '<broadcast>', 9
    ensure
      socket.close
    end
  end
end
