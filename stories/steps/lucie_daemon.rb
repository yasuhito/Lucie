steps_for( :lucie_daemon ) do
  Given 'no other lucied is running' do
    kill_lucied
  end


  Given 'I start lucied' do
    system './lucie start --lucied'
  end


  When 'I start lucied' do
    @stdout, @stderr = output_with( './lucie start --lucied --debug' )
  end


  When 'I start another lucied' do
    @stdout, @stderr = output_with( './lucie start --lucied' )
  end


  When 'I stop lucied' do
    @stdout, @stderr = output_with( './lucie stop --lucied' )
  end


  Then 'PID file is created' do
    FileTest.exists?( lucied_pid_fn ).should == true
    IO.read( lucied_pid_fn ).to_i.should == lucied_pid
  end


  Then 'pwd is RAILS_ROOT' do
    @stdout.chomp.split( "\n" ).include?( "[debug] pwd = #{ File.expand_path( RAILS_ROOT ) }" ).should be_true
  end


  Then 'lucied successfully stops' do
    lucied_pid.should == nil
  end


  Then "I get message 'Lucie daemon stopped.'" do
    @stdout.chomp.should == 'Lucie daemon stopped.'
  end


  Then 'PID file is deleted' do
    FileTest.exists?( lucied_pid_fn ).should_not == true
  end


  Then "I get error message '$error_message'" do | msg |
    @stderr.chomp.should == msg
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
