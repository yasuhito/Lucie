require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SuperReboot do
  before :each do | each |
    @node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    @messenger = StringIO.new( "" )
    @debug_options = { :dry_run => false, :verbose => true, :messenger => @messenger }
    @super_reboot = SuperReboot.new( @debug_options )
    watch_dog = mock( "watch dog" ).as_null_object
    RebootWatchDog.should_receive( :new ).and_return( watch_dog )
  end


  context "when failed to reboot with script" do
    it "should fall back to ssh reboot" do
      logger = mock( "logger" ).as_null_object
      @super_reboot.should_receive( :run ).with( "false yutaro", @debug_options, @messenger ).and_raise( RuntimeError )
      @super_reboot.stub( :run ).with( /\Assh.*root@yutaro "reboot"\Z/, @debug_options, @messenger )
      @super_reboot.start_first_stage @node, mock( "syslog" ).as_null_object, logger, "false"
      history.should include( "Reboot script 'false yutaro' failed." )
      history.should include( "Rebooting yutaro via ssh ..." )
    end
  end


  context "when failed to super reboot" do
    it "should raise" do
      logger = mock( "logger" )
      @super_reboot.stub( :run ).with( "false yutaro", @debug_options, @messenger ).and_raise( RuntimeError )
      @super_reboot.stub( :run ).with( /\Assh.*root@yutaro "reboot"\Z/, @debug_options, @messenger ).and_raise( RuntimeError )
      lambda do
        @super_reboot.start_first_stage @node, mock( "syslog" ).as_null_object, logger
      end.should raise_error( RuntimeError, "failed to super-reboot" )
    end
  end


  def history
    @messenger.string.split( "\n" )
  end
end
