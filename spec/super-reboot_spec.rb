require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SuperReboot do
  before :each do | each |
    @node = mock( "node", :name => "yutaro", :ip_address => "192.168.0.1", :mac_address => "11:22:33:44:55:66" )
    @html_logger = mock( "html logger" ).as_null_object
    @messenger = StringIO.new( "" )
    @super_reboot = SuperReboot.new( @html_logger, { :dry_run => false, :verbose => true }, @messenger )
    watch_dog = mock( "watch dog" ).as_null_object
    RebootWatchDog.should_receive( :new ).and_return( watch_dog )
  end


  context "when failed to reboot with script" do
    it "should fall back to ssh reboot" do
      logger = mock( "logger" ).as_null_object
      @super_reboot.start_first_stage @node, mock( "syslog" ).as_null_object, logger, "false"
      history.should include( "Reboot script 'false yutaro' failed." )
      history.should include( "Rebooting yutaro via ssh ..." )
    end
  end


  context "when failed to super reboot" do
    it "should request manual reboot" do
      logger = mock( "logger" )
      logger.should_receive( :info ).once.with( "Rebooting" )
      logger.should_receive( :info ).once.with( "Requesting manual reboot" )
      @super_reboot.start_first_stage @node, mock( "syslog" ).as_null_object, logger
    end
  end


  def history
    @messenger.string.split( "\n" )
  end
end
