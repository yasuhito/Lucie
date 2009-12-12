require File.join( File.dirname( __FILE__ ), "spec_helper" )


class Blocker 
  describe PidFile do
    it "should store and recall pid" do
      PidFile.store "test", 100
      PidFile.recall( "test" ).should == 100
    end
  end
end


describe Blocker do
  before :each do
    Blocker.release lock_name
  end


  after :each do
    Blocker.release lock_name
  end


  it "should acuire a lock and release it automatically" do
    Blocker.start lock_name do
      FileTest.exists?( Blocker::PidFile.path( lock_name ) ).should be_true
    end
    FileTest.exists?( Blocker::PidFile.path( lock_name ) ).should be_false
  end


  it "should store its PID in its pid file" do
    Kernel.stub!( :fork ).and_yield
    Blocker::PidFile.should_receive( :store ).with( lock_name, 100 )
    Blocker.fork( lock_name ) do 100 end
  end


  it "should block if an another process already aquired a lock" do
    Blocker.block lock_name
    lambda do
      Blocker.block lock_name
    end.should raise_error( RuntimeError, "Another process is already running." )
  end


  def lock_name
    "test"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

