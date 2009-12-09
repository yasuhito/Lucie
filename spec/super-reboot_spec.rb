require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SuperReboot do
  before :each do | each |
    @node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    @messenger = StringIO.new( "" )
    @tracker = mock( "tracker" ).as_null_object
    BootSequenceTracker.stub!( :new ).and_return( @tracker )
  end


  it "should wait until manual reboot" do
    @tracker.should_receive( :wait_manual_reboot ).once.ordered
    @tracker.should_receive( :wait_nfsroot ).once.ordered
    @tracker.should_receive( :wait_pong ).once.ordered
    @tracker.should_receive( :wait_sshd ).once.ordered

    SuperReboot.new( @node, dummy_syslog, dummy_logger, debug_options ).wait_manual_reboot
  end


  it "should wait third reboot" do
    @tracker.should_receive( :wait_dhcpack ).once.ordered
    @tracker.should_receive( :wait_pxe_localboot ).once.ordered
    @tracker.should_receive( :wait_pong ).once.ordered
    @tracker.should_receive( :wait_sshd ).once.ordered

    SSH.stub!( :new ).and_return( mock( "ssh" ).as_null_object )
    SuperReboot.new( @node, dummy_syslog, dummy_logger, debug_options ).reboot_to_finish_installation
  end


  context "when failed to reboot with script" do
    it "should fall back to ssh reboot" do
      SSH.stub!( :new ).and_return( mock( "ssh" ).as_null_object )
      SuperReboot.new( @node, dummy_syslog, dummy_logger, debug_options ).start_first_stage "false"

      history.should include( "Reboot script failed." )
      history.should include( "Rebooting yutaro via ssh ..." )
    end
  end


  context "when failed to super reboot" do
    it "should raise" do
      lambda do
        SuperReboot.new( @node, dummy_syslog, dummy_logger, debug_options ).start_first_stage
      end.should raise_error( RuntimeError, "failed to super-reboot" )
    end
  end


  def debug_options
    debug_options = { :dry_run => false, :verbose => true, :messenger => @messenger }
  end


  def dummy_syslog
    mock( "syslog" ).as_null_object
  end


  def dummy_logger
    mock( "logger" ).as_null_object
  end


  def history
    @messenger.string.split( "\n" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
