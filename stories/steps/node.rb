steps_for :node do
  Given 'lucied is started' do
    system './lucie stop --lucied'
    system './lucie start --lucied'
  end


  Given 'lucied is stopped' do
    system './lucie stop --lucied'
  end


  Given 'no installer is added' do
    installers = Dir.glob( File.join( Configuration.installers_directory, '*' ) ).join( ' ' )
    system "sudo rm -rf #{ installers }"
  end


  Given '$installer installer is added' do | installer |
    @installer = installer
    system "./installer add #{ installer } --url https://lucie.is.titech.ac.jp/svn/trunk/config/demo --no-builder"
  end


  When 'I add $node' do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add #{ node } --installer #{ @installer } -a #{ dummy_ip_address } -n 255.255.255.0 -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  Then 'we get no error' do
    @stderr.should == ''
  end


  Then "the error message should be: '$error'" do | error |
    @stderr.chomp.should == error
  end


  Then 'MAC address file should be created at $mac_file' do | mac_file |
    @mac_file = mac_file
    FileTest.exists?( mac_file ).should be_true
  end


  Then 'installer file should be created at $installer_file' do | installer_file |
    FileTest.exists?( installer_file ).should be_true
  end


  Then 'the MAC address file should include gateway definition' do
    expected = "gateway_address:#{ dummy_gateway_address }"
    IO.read( @mac_file ).split( "\n" ).include?( expected ).should be_true
  end


  Then 'the MAC address file should include ip_address definition' do
    expected = "ip_address:#{ dummy_ip_address }"
    IO.read( @mac_file ).split( "\n" ).include?( expected ).should be_true
  end


  Then 'the MAC address file should include netmask_address definition' do
    expected = "netmask_address:255.255.255.0"
    IO.read( @mac_file ).split( "\n" ).include?( expected ).should be_true
  end


  Then 'node directory should not be removed' do
    FileTest.exists?( File.join( Configuration.nodes_directory, @node ) ).should be_true
  end


  Given '$node_name is added' do | node |
    add_fresh_node node
  end


  Given '$node_name is succeeded to install' do | node |
    add_success_log node
  end


  Given '$node_name is failed to install' do | node |
    add_failure_log node
  end


  Given '$node_name is incomplete' do | node |
    add_incomplete_log node
  end


  Given '$node_name is enabled with $installer installer' do | node, installer |
    enable_node node, installer
  end


  Given '$node_name is disabled' do | node |
    disable_node node
  end


  Given 'no node is added yet' do
    FileUtils.rm_r Dir.glob( File.join( Configuration.nodes_directory, '*' ) )
  end


  When 'I run $command' do | command |
    @output, @error = output_with( command )
  end


  Then "the output should look like '$message'" do | message |
    @output.split( "\n" ).collect do | each |
      each.strip
    end.include?( message.strip ).should be_true
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

