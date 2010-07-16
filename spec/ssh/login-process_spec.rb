require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


describe SSH::LoginProcess do
  it "should login to a node" do
    Kernel.should_receive( :system ).with( "ssh -i #{ File.expand_path "~/.ssh/id_rsa" } #{ SSH::OPTIONS } root@yutaro00" ).and_return( true )

    ssh = SSH.new
    ssh.login( "yutaro00" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
