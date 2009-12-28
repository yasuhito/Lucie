require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe ProcessPool do
  before :each do
    @dummy_node = mock( "yutaro_node", :name => "yutaro_node" )
    @ppool = ProcessPool.new
  end


  it "should dispatch a code block as a new sub-process" do
    Kernel.stub!( :fork ).and_yield.and_return( "PID" )
    Process.should_receive( :waitpid2 ).with( "PID" ).and_return( [ "PID", status0 ] )

    @ppool.dispatch( @dummy_node ) do | node |
      node.name.should == "yutaro_node"
    end
    @ppool.shutdown
  end


  it "should raise if sub-process exitted abnormally" do
    Kernel.stub!( :fork ).and_return( "PID" )
    Process.should_receive( :waitpid2 ).with( "PID" ).and_return( [ "PID", status1 ] )

    @ppool.dispatch( @dummy_node ) {}
    lambda do
      @ppool.shutdown
    end.should raise_error( RuntimeError )
  end


  it "should ignore if ECHILD raised" do
    Kernel.stub!( :fork ).and_return( "PID" )
    Process.stub!( :waitpid2 ).with( "PID" ).and_raise( Errno::ECHILD )

    @ppool.dispatch( @dummy_node ) {}
    lambda do
      @ppool.shutdown
    end.should_not raise_error
  end


  it "should kill all sub-processes" do
    Kernel.stub!( :fork ).and_return( "PID1", "PID2", "PID3" )
    Process.stub!( :waitpid2 ).and_return( [ "PID", status0 ] )

    Process.should_receive( :kill ).with( "TERM", "PID1" ).ordered
    Process.should_receive( :kill ).with( "TERM", "PID2" ).ordered
    Process.should_receive( :kill ).with( "TERM", "PID3" ).ordered

    @ppool.dispatch( @dummy_node ) {}
    @ppool.dispatch( @dummy_node ) {}
    @ppool.dispatch( @dummy_node ) {}
    @ppool.killall
  end


  def status0
    status = "STATUS"
    status.stub!( :exitstatus ).and_return( 0 )
    status
  end


  def status1
    status = "STATUS"
    status.stub!( :exitstatus ).and_return( 1 )
    status
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
