require File.dirname( __FILE__ ) + '/../spec_helper'


describe WakeOnLan, 'when calling WakeOnLan.wake' do
  it 'should send magick packet' do
    socket = Object.new

    # expects
    UDPSocket.expects( :open ).returns( socket )
    socket.expects( :setsockopt ).with( Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1 )
    socket.expects( :send )
    socket.expects( :close )

    # when
    WakeOnLan.wake '00:00:00:00:00:00'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
