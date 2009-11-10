require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Popen3
  describe Popen3 do
    it "should spawn a subprocess and redirect its stdout and stderr" do
      Kernel.stub!( :fork ).and_yield

      STDIN.should_receive( :reopen ).once.with( an_instance_of( IO ) )
      STDOUT.should_receive( :reopen ).once.with( an_instance_of( IO ) )
      STDERR.should_receive( :reopen ).once.with( an_instance_of( IO ) )
      Kernel.should_receive( :exec ).once.with( "DUMMY COMMAND" )

      process = Popen3.new
      process.popen3( "DUMMY COMMAND", "LC_ALL" => "C" ) do | stdout, stderr |
        stdout.should be_a_kind_of( IO )
        stderr.should be_a_kind_of( IO )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
