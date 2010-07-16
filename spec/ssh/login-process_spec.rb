require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


describe SSH::LoginProcess do
  it "should login to a node" do
    Kernel.should_receive( :system ).with( /\Assh .* root@yutaro00\Z/ ).and_return( true )

    ssh = SSH.new
    ssh.login( "yutaro00" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
