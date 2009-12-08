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
    @tracker.syslog = dummy_syslog( <<-EOF )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.cfg/01-11-22-33-44-55-66
Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename lucie
EOF
    @tracker.wait_pxe
  end


  it "should wait until node rebooted manually" do
    @messenger.should_receive( :puts ).with( "Please reboot yutaro manually." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request PXE boot loader configuration file ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request Lucie kernel ..." ).once.ordered
    @tracker.syslog = dummy_syslog( <<-EOF )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.cfg/01-11-22-33-44-55-66
Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename lucie
EOF

    @tracker.wait_manual_reboot
  end


  it "should wait until node boots from local disk with PXE" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request PXE boot loader ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to request PXE boot loader configuration file ..." ).once.ordered
    @tracker.syslog = dummy_syslog( <<-EOF )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from 192.168.0.1 filename pxelinux.cfg/01-11-22-33-44-55-66
EOF

    @tracker.wait_pxe_localboot
  end


  it "should wait until node receives DHCPACK" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to send DHCPDISCOVER ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to receive DHCPOFFER ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to send DHCPREQUEST ..." ).once.ordered
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to receive DHCPACK ..." ).once.ordered
    @tracker.syslog = dummy_syslog( <<-EOF )
Jun 17 21:00:15 lucie_server dhcpd: DHCPDISCOVER from 11:22:33:44:55:66 via eth0
Jun 17 21:00:16 lucie_server dhcpd: DHCPOFFER on 192.168.0.1 to 11:22:33:44:55:66 via eth0
Jun 17 21:00:17 lucie_server dhcpd: DHCPREQUEST for 192.168.0.1 (192.168.1.100) from 11:22:33:44:55:66 via eth0
Jun 17 21:00:18 lucie_server dhcpd: DHCPACK on 192.168.0.1 to 11:22:33:44:55:66 via eth0
EOF

    @tracker.wait_dhcpack
  end


  it "should wait until node mounts nfsroot" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to mount nfsroot ..." ).once
    @tracker.syslog = dummy_syslog( "Jun 17 21:00:15 lucie_server mountd[12345]: authenticated mount request from 192.168.0.1" )

    @tracker.wait_nfsroot
  end


  it "should wait until pong" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to respond to ping ..." ).once
    Ping.should_receive( :pingecho ).with( "192.168.0.1" ).once.and_return( true )

    @tracker.wait_pong
  end


  it "should wait until no pong" do
    @messenger.should_receive( :puts ).with( "Waiting for yutaro to stop responding to ping ..." ).once
    Ping.should_receive( :pingecho ).with( "192.168.0.1" ).once.and_return( false )

    @tracker.wait_no_pong
  end


  it "should wait until sshd is up" do
    @messenger.should_receive( :puts ).with( "Waiting for sshd to start on yutaro ..." ).exactly( 3 ).times
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::EHOSTUNREACH )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once.and_raise( Errno::ECONNREFUSED )
    TCPSocket.should_receive( :open ).with( "192.168.0.1", 22 ).once

    @tracker.wait_sshd
  end


  def dummy_syslog content
    io = StringIO.new( content )
    io.stub! :seek
    io
  end
end
