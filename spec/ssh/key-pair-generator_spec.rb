require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


describe SSH::KeyPairGenerator do
  before :each do
    @generator = SSH::KeyPairGenerator.new( :dry_run => true )
    
    @user_public_key = File.expand_path( "~/.ssh/id_rsa.pub" )
    @user_private_key = File.expand_path( "~/.ssh/id_rsa" )
    @lucie_public_key = File.expand_path( "~/.lucie/id_rsa.pub" )
    @lucie_private_key = File.expand_path( "~/.lucie/id_rsa" )
  end


  context "when ~/.lucie/{id_rsa,id_rsa.pub} exists" do
    it "should not generate a new key pair" do
      FileTest.stub( :exist? ).with( @lucie_public_key ).and_return( true )
      FileTest.stub( :exist? ).with( @lucie_private_key ).and_return( true )
      FileTest.stub( :exist? ).with( @user_public_key ).and_return( false )
      FileTest.stub( :exist? ).with( @user_private_key ).and_return( false )

      @generator.should_not_receive( :maybe_cleanup_old_key_pair )
      @generator.should_not_receive( :ssh_keygen )

      @generator.start
    end
  end


  context "when ~/.ssh/{id_rsa,id_rsa.pub} exists" do
    it "should not generate a new key pair" do
      FileTest.stub( :exist? ).with( @lucie_public_key ).and_return( false )
      FileTest.stub( :exist? ).with( @lucie_private_key ).and_return( false )
      FileTest.stub( :exist? ).with( @user_public_key ).and_return( true )
      FileTest.stub( :exist? ).with( @user_private_key ).and_return( true )

      @generator.should_not_receive( :maybe_cleanup_old_key_pair )
      @generator.should_not_receive( :ssh_keygen )

      @generator.start
    end
  end


  context "when ~/.lucie/{id_rsa,id_rsa.pub} and ~/.ssh/{id_rsa,id_rsa.pub} exist" do
    it "should not generate a new key pair" do
      FileTest.stub( :exist? ).with( @lucie_public_key ).and_return( true )
      FileTest.stub( :exist? ).with( @lucie_private_key ).and_return( true )
      FileTest.stub( :exist? ).with( @user_public_key ).and_return( true )
      FileTest.stub( :exist? ).with( @user_private_key ).and_return( true )

      @generator.should_not_receive( :maybe_cleanup_old_key_pair )
      @generator.should_not_receive( :ssh_keygen )

      @generator.start
    end
  end


  context "when ~/.lucie/{id_rsa,id_rsa.pub} and ~/.ssh/{id_rsa,id_rsa.pub} does not exist" do
    it "should generate a new key pair" do
      FileTest.stub( :exist? ).with( @lucie_public_key ).and_return( false )
      FileTest.stub( :exist? ).with( @lucie_private_key ).and_return( false )
      FileTest.stub( :exist? ).with( @user_public_key ).and_return( false, true )
      FileTest.stub( :exist? ).with( @user_private_key ).and_return( true )

      @generator.should_receive( :maybe_cleanup_old_key_pair )
      @generator.should_receive( :ssh_keygen )

      @generator.start
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
