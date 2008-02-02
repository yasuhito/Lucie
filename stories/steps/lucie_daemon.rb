steps_for( :lucie_daemon ) do
  Given 'no other lucied is running' do
    kill_lucied
  end


  When 'I start lucied' do
    @output = output_with( './lucie start --lucied --debug' )
  end


  When 'I start another lucied' do
    @output = output_with( './lucie start --lucied' )
  end


  When 'I stop lucied' do
    @output = output_with( './lucie stop --lucied' ).chomp
  end


  Then 'PID file is created' do
    FileTest.exists?( lucied_pid_fn ).should == true
    IO.read( lucied_pid_fn ).to_i.should == lucied_pid
  end


  Then 'pwd is RAILS_ROOT' do
    @output.chomp.split( "\n" ).include?( "[debug] pwd = #{ File.expand_path( RAILS_ROOT ) }" ).should be_true
  end


  Then 'lucied successfully stops' do
    lucied_pid.should == nil
  end


  Then "I get message 'Lucie daemon stopped.'" do
    @output.should == 'Lucie daemon stopped.'
  end


  Then 'PID file is deleted' do
    FileTest.exists?( lucied_pid_fn ).should_not == true
  end


  Then "I get error message '$error_message'" do | msg |
    @output.chomp.should == msg
  end
end
