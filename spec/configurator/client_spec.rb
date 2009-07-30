require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Configurator
  describe Client do
    context "initializing a client" do
      before :each do
        @ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( @ssh )
      end


      it "should create a configurator base directory if not found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" ).and_raise( "test -d failed" )
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "mkdir -p /var/lib/lucie/config" )
        Configurator::Client.new( @scm ).setup "DUMMY_IP_ADDRESS"
      end


      it "should not create a configurator base directory if found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" )
        Configurator::Client.new( @scm ).setup "DUMMY_IP_ADDRESS"
      end
    end


    context "creating a configuration repository clone on a client" do
      it "should make a clone repository on the client" do
        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )
        Configuration.stub!( :temporary_directory ).and_return( "/tmp/lucie" )

        ssh.should_receive( :cp_r ).with( "DUMMY_IP_ADDRESS", "/tmp/lucie/config/ssh___myrepos.org__lucie.local", "/var/lib/lucie/config" )

        Client.new( @scm ).install "DUMMY_IP_ADDRESS", "ssh://myrepos.org//lucie"
      end
    end


    context "when starting configuration process" do
      it "should execute configuration tool" do
        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )

        ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "ls -1 /var/lib/ldb" ).twice.and_return( "LDB_CHECKOUT_DIRECTORY" )
        ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "cd /var/lib/lucie/config/LDB_CHECKOUT_DIRECTORY/scripts && eval `ssh -i /home/yasuhito/project/lucie/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@DUMMY_IP_ADDRESS /var/lib/lucie/config/LDB_CHECKOUT_DIRECTORY/bin/ldb env` && make" )

        Client.new( @scm ).start "DUMMY_IP_ADDRESS"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
