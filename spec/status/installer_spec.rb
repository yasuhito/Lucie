require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Status
  describe Installer do
    before :each do
      FileUtils.rm_rf base_dir
      @status = Installer.new( base_dir )
    end


    after :each do
      FileUtils.rm_rf base_dir
    end


    it "should return install id" do
      @status.install_id.should == 100
    end


    context "when failed to install" do
      it "should create a failed status file" do
        @status.start!
        @status.fail!
        FileTest.exists?( File.join( base_dir, "installer_status.failed.in1s" ) ).should be_true
        @status.failed?.should be_true
      end
    end


    def base_dir
      "/tmp/node-yasuhito/install-100"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
