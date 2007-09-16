require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/popen3'


class Popen3Test < Test::Unit::TestCase
  def test_popen3_with_no_block_returns_a_set_of_pipes
    Kernel.stubs( :fork )
    Lucie::Log.stubs( :debug )

    tochild, fromchild, childerr = popen3( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )

    assert_kind_of IO, tochild
    assert_kind_of IO, fromchild
    assert_kind_of IO, childerr
  end


  def test_tochild_pipe_is_set_sync
    Kernel.stubs( :fork )
    Lucie::Log.stubs( :debug )

    tochild, = popen3( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )

    assert tochild.sync
  end


  def test_wait
    Kernel.expects( :fork ).times( 1 ).returns( 'DUMMY_PID' )
    Lucie::Log.stubs( :debug )
    Process.expects( :wait ).times( 1 ).with( 'DUMMY_PID' )

    process = Popen3::Popen3.new( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
    process.popen3
    process.wait
  end


  def test_popen3_with_block_yields_a_set_of_pipes
    Kernel.stubs( :fork )
    Lucie::Log.stubs( :debug )

    popen3( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' ) do | tochild, fromchild, childerr |
      assert_kind_of IO, tochild
      assert_kind_of IO, fromchild
      assert_kind_of IO, childerr
    end
  end


  def test_popen3
    pipe_mock = mock( 'PIPE' )
    pipe_mock.expects( :closed? ).at_least_once.returns( false )
    pipe_mock.expects( :close ).at_least_once
    pipe_mock.expects( :sync= ).at_least_once

    IO.expects( :pipe ).times( 3 ).returns( [ pipe_mock, pipe_mock ] )

    Kernel.expects( :fork ).times( 1 ).yields
    Kernel.expects( :exec ).times( 1 ).with( 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
     
    STDIN.expects( :reopen ).times( 1 )
    STDOUT.expects( :reopen ).times( 1 )
    STDERR.expects( :reopen ).times( 1 )

    Lucie::Log.stubs( :debug )

    popen3( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
