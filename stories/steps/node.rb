require 'fileutils'


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


  When "I add '$node' node" do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add #{ node } --installer #{ @installer } -a #{ dummy_ip_address } -n 255.255.255.0 -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  When 'I add a node with no name' do
    @stdout, @stderr = output_with( "./node add --installer #{ @installer } -a #{ dummy_ip_address } -n 255.255.255.0 -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  When 'I add a node with no installer name' do
    @stdout, @stderr = output_with( "./node add TEST_NODE -a #{ dummy_ip_address } -n 255.255.255.0 -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  When "I add '$node' node with no IP address" do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add TEST_NODE --installer #{ @installer } -n 255.255.255.0 -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  When "I add '$node' node with no netmask" do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add TEST_NODE -a #{ dummy_ip_address } --installer #{ @installer } -g #{ dummy_gateway_address } -m 00:00:00:00:00:00" )
  end


  When "I add '$node' node with no gateway" do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add TEST_NODE -a #{ dummy_ip_address } --installer #{ @installer } -n 255.255.255.0 -m 00:00:00:00:00:00" )
  end


  When "I add '$node' node with no MAC address" do | node |
    @node = node
    @stdout, @stderr = output_with( "./node add TEST_NODE -a #{ dummy_ip_address } --installer #{ @installer } -n 255.255.255.0 -g #{ dummy_gateway_address }" )
  end


  When 'I remove $node' do | node |
    @stdout, @stderr = output_with( './node remove TEST_NODE' )
  end


  Then 'we get no error' do
    @stderr.should == ''
  end


  Then "the error message should be: '$error'" do | error |
    @stderr.split( "\n" ).first.chomp.should == error
  end


  Then 'MAC address file should be created at $mac_file' do | mac_file |
    @mac_file = mac_file
    FileTest.exists?( mac_file ).should be_true
  end


  Then 'MAC address file $mac_file should be removed' do | mac_file |
    FileTest.exists?( mac_file ).should_not be_true
  end


  Then 'installer file should be created at $installer_file' do | installer_file |
    FileTest.exists?( installer_file ).should be_true
  end


  Then 'installer file $installer_file should be removed' do | installer_file |
    FileTest.exists?( installer_file ).should_not be_true
  end


  Then 'TFTP file $tftp_file should be removed' do | tftp_file |
    FileTest.exists?( tftp_file ).should_not be_true
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


  Given '$node is disabled with $installer' do | node, installer |
    disable_node node, installer
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
