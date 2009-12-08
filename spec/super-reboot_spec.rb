require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SuperReboot do
  before :each do | each |
    @node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    @messenger = StringIO.new( "" )
    @debug_options = { :dry_run => false, :verbose => true, :messenger => @messenger }
    tracker = mock( "tracker" ).as_null_object
    BootSequenceTracker.should_receive( :new ).and_return( tracker )
  end


  context "when failed to reboot with script" do
    it "should fall back to ssh reboot" do
      ssh = mock( "ssh" )
      ssh.stub( :sh ).with( "yutaro", "shutdown -r now" )
      SSH.stub!( :new ).and_return( ssh )
      SuperReboot.new( @debug_options ).start_first_stage @node, mock( "syslog" ).as_null_object, mock( "logger" ).as_null_object, "false"
      history.should include( "Reboot script 'false yutaro' failed." )
      history.should include( "Rebooting yutaro via ssh ..." )
    end
  end


  context "when failed to super reboot" do
    it "should raise" do
      lambda do
        SuperReboot.new( @debug_options ).start_first_stage @node, mock( "syslog" ).as_null_object, mock( "logger" )
      end.should raise_error( RuntimeError, "failed to super-reboot" )
    end
  end


  def history
    @messenger.string.split( "\n" )
  end
end
