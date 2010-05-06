require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


describe SSH::ShProcess do
  it "should keep output log" do
    shell = mock( "shell" ).as_null_object
    shell.stub( :on_stdout ).and_yield( "stdout" )
    shell.stub( :on_stderr ).and_yield( "stderr" )
    SubProcess.stub( :create ).and_yield( shell )

    ssh = SSH.new
    ssh.sh( "yutaro00", "echo 'hello world'" )
    ssh.output.should == <<-EOF
stdout
stderr
EOF
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
