# -*- coding: utf-8 -*-
require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


describe SSH::Home, %{with ssh_home = "\#{tmpdir}/ssh_home"} do
  let( :ssh_home ) { File.join Dir.tmpdir, "ssh_home" }
  let( :public_key ) { File.join ssh_home, "id_rsa.pub" }
  let( :authorized_keys ) { File.join ssh_home, "authorized_keys" }

  let( :ssh_home_exists ) { FileUtils.mkdir_p ssh_home }


  before :each do
    @home = SSH::Home.new( ssh_home )
  end


  after :each do
    FileUtils.rm_rf ssh_home
  end


  context "when creating ssh_home" do
    before :each do
      @home.stub( :maybe_chmod )
      @home.stub( :maybe_authorize_public_key )
      @home.stub( :maybe_chmod_authorized_keys )
    end


    it "should create ssh_home if it does not exist" do
      FileUtils.rm_rf ssh_home
      @home.should_receive( :mkdir_p ).with( ssh_home, {} )
      @home.setup
    end


    it "should not create ssh_home if it already exists" do
      FileUtils.mkdir_p ssh_home
      @home.should_not_receive( :mkdir_p ).with( ssh_home, {} )
      @home.setup
    end
  end


  # [???] 0700 で合ってるの？ man 参照
  context "when checking the permission of ssh_home" do
    before :each do
      ssh_home_exists
      @home.stub( :maybe_authorize_public_key )
      @home.stub( :maybe_chmod_authorized_keys )
    end


    it "should not chmod ssh_home if its permission == 0700" do
      FileUtils.chmod 0700, ssh_home
      @home.should_not_receive( :run ).with( "chmod 0700 #{ ssh_home }", {} )
      @home.setup
    end


    it "should chmod ssh_home if its permission != 0700" do
      FileUtils.chmod 0444, ssh_home
      @home.should_receive( :run ).with( "chmod 0700 #{ ssh_home }", {} )
      @home.setup
    end
  end


  context "when authorizing user's public key" do
    before :each do
      ssh_home_exists
      File.open( public_key, "w" ) do | f |
        f.puts "PUBLIC KEY"
      end
      @home.stub( :public_key ).and_return( public_key )
      @home.stub( :maybe_chmod )
      @home.stub( :maybe_chmod_authorized_keys )
    end


    it "should not authorize the key if already authorized" do
      FileUtils.cp public_key, authorized_keys
      @home.should_not_receive( :run ).with( "cat #{ public_key } >> #{ authorized_keys }", {} )
      @home.setup
    end


    it "should authorize the key if not authorized" do
      @home.should_receive( :run ).with( "cat #{ public_key } >> #{ authorized_keys }", {} )
      @home.setup
    end
  end


  # [???] 0644 で合ってるの？ man 参照
  context "when the permission of authorized_keys == 0644" do
    it "should not chmod authorized_keys" do
      ssh_home_exists
      FileUtils.touch authorized_keys
      FileUtils.chmod 0644, authorized_keys

      @home.stub( :maybe_chmod )
      @home.stub( :maybe_authorize_public_key )
      @home.should_not_receive( :run ).with( "chmod 0644 #{ authorized_keys }", {} )

      @home.setup
    end
  end


  context "when the permission of authorized_keys != 0644" do
    it "should chmod authorized_keys" do
      ssh_home_exists
      FileUtils.touch authorized_keys
      FileUtils.chmod 0444, authorized_keys

      @home.stub( :maybe_chmod )
      @home.stub( :maybe_authorize_public_key )
      @home.should_receive( :run ).with( "chmod 0644 #{ authorized_keys }", {} )

      @home.setup
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
