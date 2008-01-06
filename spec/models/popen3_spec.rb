require File.dirname( __FILE__ ) + '/../spec_helper'


describe Popen3, 'when executing popen3' do
  before( :each ) do
    IO.stubs( :pipe ).returns( [ pipe_stub, pipe_stub ] )

    STDIN.stubs( :reopen )
    STDOUT.stubs( :reopen )
    STDERR.stubs( :reopen )

    Lucie::Log.stubs( :debug )
  end


  it 'should execute command' do
    Kernel.expects( :fork ).times( 1 ).yields
    Kernel.expects( :exec ).times( 1 ).with( 'TEST_COMMAND TEST_ARG1 TEST_ARG2' )

    popen3( 'TEST_COMMAND TEST_ARG1 TEST_ARG2', { :env => { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' } } )
  end


  it 'should execute command with block' do
    Kernel.expects( :fork ).times( 1 ).yields
    Kernel.expects( :exec ).times( 1 ).with( 'TEST_COMMAND TEST_ARG1 TEST_ARG2' )

    popen3( 'TEST_COMMAND TEST_ARG1 TEST_ARG2', { :env => { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' } } ) do | tochild, fromchild, childerr |
      # do nothing here.
    end
  end


  it 'should call Process.wait if Popen3#wait called' do
    Kernel.stubs( :fork ).returns( 'DUMMY_PID' )
    Lucie::Log.stubs( :debug )

    Process.expects( :wait ).times( 1 ).with( 'DUMMY_PID' )

    process = Popen3::Popen3.new( 'TEST_COMMAND TEST_ARG1 TEST_ARG2', { :env => { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' } } )
    # get child process's pid
    process.popen3
    # and wait
    process.wait
  end


  def pipe_stub
    pipe = Object.new
    pipe.stubs( :closed? )
    pipe.stubs( :close )
    pipe.stubs( :sync= )
    pipe
  end
end
