require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class SSH
  describe Path do
    subject {
      class TestSSHPath
        include SSH::Path
      end
      TestSSHPath.new
    }


    let( :user_ssh_home ) { File.expand_path "~/.ssh" }
    let( :user_public_key ) { File.expand_path "~/.ssh/id_rsa.pub" }
    let( :user_private_key ) { File.expand_path "~/.ssh/id_rsa" }

    let( :lucie_ssh_home ) { File.expand_path "~/.lucie" }
    let( :lucie_public_key ) { File.expand_path "~/.lucie/id_rsa.pub" }
    let( :lucie_private_key ) { File.expand_path "~/.lucie/id_rsa" }


    its( :authorized_keys ) { should == File.expand_path( "~/.ssh/authorized_keys" ) }


    context "when ~/.ssh/{id_rsa.pub,id_rsa} exist" do
      before :each do
        FileTest.stub!( :exist? ).with( user_public_key ).and_return( true )
        FileTest.stub!( :exist? ).with( user_private_key ).and_return( true )
        FileTest.stub!( :exist? ).with( lucie_public_key ).and_return( false )
        FileTest.stub!( :exist? ).with( lucie_private_key ).and_return( false )
      end


      its( :ssh_home ) { should == user_ssh_home }
      its( :public_key ) { should == user_public_key }
      its( :private_key ) { should == user_private_key }
    end


    context "when ~/.lucie/{id_rsa.pub,id_rsa} exist" do
      before :each do
        FileTest.stub!( :exist? ).with( lucie_public_key ).and_return( true )
        FileTest.stub!( :exist? ).with( lucie_private_key ).and_return( true )
        FileTest.stub!( :exist? ).with( user_public_key ).and_return( false )
        FileTest.stub!( :exist? ).with( user_private_key ).and_return( false )
      end


      its( :ssh_home ) { should == lucie_ssh_home }
      its( :public_key ) { should == lucie_public_key }
      its( :private_key ) { should == lucie_private_key }
    end


    context "when no ssh keypair found" do
      before :each do
        FileTest.stub!( :exist? ).with( lucie_public_key ).and_return( false )
        FileTest.stub!( :exist? ).with( lucie_private_key ).and_return( false )
        FileTest.stub!( :exist? ).with( user_public_key ).and_return( false )
        FileTest.stub!( :exist? ).with( user_private_key ).and_return( false )
      end


      it "should raise error when getting ssh_home" do
        lambda do
          subject.ssh_home
        end.should raise_error( "No ssh keypair found!" )
      end


      it "should raise error when getting public_key" do
        lambda do
          subject.public_key
        end.should raise_error( "No ssh keypair found!" )
      end


      it "should raise error when getting private_key" do
        lambda do
          subject.private_key
        end.should raise_error( "No ssh keypair found!" )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

