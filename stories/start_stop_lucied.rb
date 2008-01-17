require 'stories/helper'


Story 'Start/Stop lucied daemon',
%(As a cluster administrator
  I want to start/stop lucied process
  So that I can run 'node' and 'installer' commands without root privilege) do


  Scenario "start lucied succeeds" do
    Given 'no other lucied is running' do
      system( './lucie stop --lucied' )
    end

    When 'I start lucied' do
      @stdout, @stderr = output_with( './lucie start --lucied --debug' )
    end

    Then 'PID file is created and flocked' do
      FileTest.exists?( pid_fn ).should == true
      IO.read( pid_fn ).to_i.should satisfy do | pid |
        pid > 0
      end
    end

    Then 'pwd is RAILS_ROOT' do
      @stderr.chomp.split( "\n" ).include?( "DEBUG: pwd = #{ File.expand_path( RAILS_ROOT ) }" ).should be_true
    end
  end


  Scenario "stop lucied succeeds" do
    When 'I stop lucied' do
      @stdout, @stderr = output_with( './lucie stop --lucied' )
    end

    Then 'lucied successfully stops' do
      @stderr.should == ''
    end

    Then 'I get message', 'Lucie daemon stopped.' do | message |
      @stdout.chomp.should == message
    end

    Then 'PID file is deleted' do
      FileTest.exists?( './tmp/pids/lucied.pid' ).should_not == true
    end
  end


  Scenario 'start lucied fails if another lucied is running' do
    Given 'no other lucied is running'
    When 'I start lucied'
    When 'I start another lucied' do
      @stdout, @stderr = output_with( './lucie start --lucied' )
    end

    Then 'I get error message', 'FAILED: Another Lucie daemon is already running.' do | message |
      @stdout.chomp.should == ''
      @stderr.chomp.should == message
    end
  end


  Scenario 'stop lucied fails if no lucied is running' do
    Given 'no other lucied is running'
    When 'I stop lucied'
    Then 'I get message', 'Lucie daemon not running (no pid file).'
  end


  def pid_fn
    File.expand_path File.join( RAILS_ROOT, 'tmp/pids/lucied.pid' )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
