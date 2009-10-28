require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Configurator do
  before :each do
    @node = mock( "node" )
  end


  context "guessing scm" do
    it "should determine scm" do
      Configurator::Client.should_receive( :guess_scm ).and_return( "Mercurial" )
      Configurator.guess_scm( @node ).should == "Mercurial"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
