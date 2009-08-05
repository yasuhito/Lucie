require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Scm do
  context "creating a client" do
    it "should return a client" do
      Scm.from( :mercurial ).should be_instance_of( Scm::Mercurial )
      Scm.from( :subversion ).should be_instance_of( Scm::Subversion )
      Scm.from( :git ).should be_instance_of( Scm::Git )
    end


    it "should raise if name is nil" do
      lambda do
        Scm.from nil
      end.should raise_error( "scm is not specified" )
    end


    it "should raise if unsupported scm is specified" do
      lambda do
        Scm.from "yasuhito's fabulous scm"
      end.should raise_error( "yasuhito's fabulous scm is not supported" )
    end
  end
end
