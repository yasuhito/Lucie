require 'stories/helper'


Story 'Start/Stop lucied daemon',
%(As a cluster administrator
  I want to start/stop lucied process
  So that I can run 'node' and 'installer' commands without root privilege) do


  Scenario "'start lucied' and 'stop lucied' succeeds if run with root privilege" do
    @sudo = "sudo -p 'password for %u [lucied]: '"

    When 'I start lucied as root' do
      @result = system( "#{ @sudo } ./lucie start --lucied" )
    end

    Then 'lucied successfully starts' do
      @result.should be_true
    end

    When 'I stop lucied as root' do
      @stdout, @stderr = output_with( "#{ @sudo } ./lucie stop --lucied" )
    end

    Then 'lucied successfully stops' do
      @stderr.should == ''
    end

    Then 'PID file is deleted' do
      FileTest.exists?( './tmp/pids/lucied.pid' ).should_not == true
    end
  end


  Scenario "'start lucied' fails if no root privilege" do
    When 'I start lucied as a common user' do
      @stdout, @stderr = output_with( './lucie start --lucied' )
    end

    Then 'error message should be:', 'ERROR: You must be root.' do | message |
      @stderr.should == message
    end
  end


  Scenario "'stop lucied' fails if no root privilege" do
    When 'I stop lucied as a common user' do
      @stdout, @stderr = output_with( './lucie stop --lucied' )
    end

    Then 'error message should be:', 'ERROR: You must be root.' do | message |
      @stderr.should == message
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
