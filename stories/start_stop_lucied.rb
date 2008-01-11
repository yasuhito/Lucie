require 'stories/helper'


Story 'Start/Stop lucied daemon',
%(As a cluster administrator
  I want to start/stop lucied process
  So that I can run 'node' and 'installer' commands without root privilege) do


  Scenario "'start lucied' and 'stop lucied' succeeds if run with root privilege" do
    Given 'no other lucied is running' do
      system( "./lucie stop --lucied" )
    end

    When 'I start lucied as root' do
      @result = system( "./lucie start --lucied" )
    end

    Then 'lucied successfully starts' do
      @result.should be_true
    end

    When 'I stop lucied as root' do
      @stdout, @stderr = output_with( "./lucie stop --lucied" )
    end

    Then 'lucied successfully stops' do
      @stderr.should == ''
    end

    Then 'PID file is deleted' do
      FileTest.exists?( './tmp/pids/lucied.pid' ).should_not == true
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
