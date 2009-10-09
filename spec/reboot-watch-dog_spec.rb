require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe RebootWatchDog do
  before :each do
    node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    logger = mock( "logger", :debug => nil )
    @watch_dog = RebootWatchDog.new( node, logger, { :verbose => false, :retry_interval => 0.001 } )
  end


  it "should wait until node boots from PXE" do
    syslog = mock( "syslog", :seek => nil )
    syslog.should_receive( :gets ).and_return( *dummy_pxe_syslog )
    @watch_dog.syslog = syslog
    @watch_dog.wait_pxe
  end


  it "should wait until sshd is up" do
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::EHOSTUNREACH )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::ECONNREFUSED )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once
    @watch_dog.wait_sshd
  end


  it "should wait until pong" do
    Ping.should_receive( :pingecho ).with( "192.168.0.1" ).once.and_return( true )
    @watch_dog.wait_pong
  end


  def dummy_pxe_syslog
    [ 
     "Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.0",
     nil,
     "Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.cfg/01-11-22-33-44-55-66",
     nil,
     "Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename lucie"
    ]
  end
end
