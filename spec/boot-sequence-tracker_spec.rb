require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe BootSequenceTracker do
  before :each do
    node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    logger = mock( "logger" ).as_null_object
    @messenger = StringIO.new
    @tracker = BootSequenceTracker.new( node, logger, { :verbose => true, :messenger => @messenger, :retry_interval => 0.001 } )
  end


  it "should wait until node boots from PXE" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request PXE boot loader ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request PXE boot loader configuration file ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request Lucie kernel ..." ).once.ordered

    @tracker.syslog = dummy_syslog
    @tracker.wait_pxe
  end


  it "should wait until sshd is up" do
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::EHOSTUNREACH )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::ECONNREFUSED )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once
    @tracker.wait_sshd
  end


  it "should wait until pong" do
    Ping.should_receive( :pingecho ).with( "192.168.0.1" ).once.and_return( true )
    @tracker.wait_pong
  end


  def dummy_syslog
    io = StringIO.new( <<-EOL )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.cfg/01-11-22-33-44-55-66
Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename lucie
EOL
    io.stub! :seek
    io
  end
end
