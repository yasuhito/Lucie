steps_for( :lucie_daemon ) do


  ################################################################################
  # Givens
  ################################################################################


  Given 'no other lucied is running' do
    kill_lucied
  end


  Given 'I start lucied' do
    system './lucie start --lucied'
  end


  ################################################################################
  # Whens
  ################################################################################


  When 'I start lucied' do
    @stdout, @stderr = output_with( './lucie start --lucied' )
  end


  When 'I start lucied with verbose option' do
    @stdout, @stderr = output_with( './lucie start --lucied --verbose' )
  end


  When 'I start another lucied' do
    @stdout, @stderr = output_with( './lucie start --lucied' )
  end


  When 'I stop lucied' do
    @stdout, @stderr = output_with( './lucie stop --lucied' )
  end


  ################################################################################
  # Thens
  ################################################################################


  Then 'PID file is created at $path' do | path |
    FileTest.exists?( File.expand_path( path ) ).should == true
  end


  Then 'PID is saved at $path' do | path |
    IO.read( File.expand_path( path ) ).to_i.should == lucied_pid
  end


  Then 'pwd is RAILS_ROOT' do
    @stdout.chomp.split( "\n" ).include?( "[debug] pwd = #{ File.expand_path( RAILS_ROOT ) }" ).should be_true
  end


  Then 'lucied successfully stops' do
    lucied_pid.should == nil
  end


  Then "I get message '$message'" do | message |
    @stdout.split( "\n" ).last.gsub( /\s+/, ' ' ).should == message
    # @stdout.chomp.split( "\n" ).include?( message ).should be_true
  end


  Then 'PID file $path is deleted' do | path |
    FileTest.exists?( File.expand_path( path ) ).should_not == true
  end


  Then "I get error message '$error_message'" do | message |
    @stderr.chomp.should == message
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
