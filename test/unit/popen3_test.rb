#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


require 'rubygems'
require 'flexmock'
require 'popen3'


class TC_Popen3 < Test::Unit::TestCase
  include FlexMock::TestCase


  def test_kernel_popen3_no_block
    prepare_popen3_no_block_mock

    tochild, fromchild, childerr = popen3( dummy_env, 'COMMAND', 'ARG1', 'ARG2' )
    assert_equal 'TOCHILD', tochild.mock_name
    assert_equal 'FROMCHILD', fromchild.mock_name
    assert_equal 'CHILDERR', childerr.mock_name
  end


  def test_wait
    prepare_popen3_no_block_mock
    flexmock( Process, 'PROCESS' ).should_receive( :wait ).with( dummy_pid ).once

    process = Popen3::Popen3.new( dummy_env, 'COMMAND', 'ARG1', 'ARG2' )
    process.popen3
    process.wait
  end


  def test_popen3_no_block
    prepare_popen3_no_block_mock

    tochild, fromchild, childerr = Popen3::Popen3.new( dummy_env, 'COMMAND', 'ARG1', 'ARG2' ).popen3
    assert_equal 'TOCHILD', tochild.mock_name
    assert_equal 'FROMCHILD', fromchild.mock_name
    assert_equal 'CHILDERR', childerr.mock_name
  end


  def test_kernel_popen3_with_block
    prepare_popen3_with_block_mock

    popen3( dummy_env, 'COMMAND', 'ARG1', 'ARG2' ) do | tochild, fromchild, childerr |
      assert_equal 'TOCHILD', tochild.mock_name
      assert_equal 'FROMCHILD', fromchild.mock_name
      assert_equal 'CHILDERR', childerr.mock_name
    end
  end


  def test_popen3_with_block
    prepare_popen3_with_block_mock

    popen3 = Popen3::Popen3.new( dummy_env, 'COMMAND', 'ARG1', 'ARG2' )

    popen3.popen3 do | tochild, fromchild, childerr |
      assert_equal 'TOCHILD', tochild.mock_name
      assert_equal 'FROMCHILD', fromchild.mock_name
      assert_equal 'CHILDERR', childerr.mock_name
    end
  end


  def prepare_popen3_with_block_mock
    tochild, fromchild, childerr = prepare_popen3_no_block_mock

    # ensure close_end_of @parent_pipe
    tochild.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    tochild.should_receive( :close ).with_no_args.once.ordered
    fromchild.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    fromchild.should_receive( :close ).with_no_args.once.ordered
    childerr.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    childerr.should_receive( :close ).with_no_args.once.ordered
  end


  def prepare_popen3_no_block_mock
    child_stdin = flexmock( 'CHILD_STDIN' )
    tochild = flexmock( 'TOCHILD' )
    fromchild = flexmock( 'FROMCHILD' )
    child_stdout = flexmock( 'CHILD_STDOUT' )
    childerr = flexmock( 'CHILDERR' )
    child_stderr = flexmock( 'CHILD_STDERR' )

    # init_pipe
    flexmock( IO ).should_receive( :pipe ).times( 3 ).with_no_args.and_return( [ child_stdin, tochild ], [ fromchild, child_stdout ], [ childerr, child_stderr ] )

    # Kernel.fork
    kernel_class_mock = flexmock( Kernel )
    kernel_class_mock.should_receive( :fork ).with( Proc ).once.and_return do | block |
      block.call
      dummy_pid
    end

    # Child Process ############################################################

    # close_end_of @parent_pipe
    tochild.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    tochild.should_receive( :close ).with_no_args.once.ordered
    fromchild.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    fromchild.should_receive( :close ).with_no_args.once.ordered
    childerr.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    childerr.should_receive( :close ).with_no_args.once.ordered

    # STDIO reopen
    flexmock( STDIN ).should_receive( :reopen ).with( on do | mock | mock.mock_name == 'CHILD_STDIN' end ).once
    flexmock( STDOUT ).should_receive( :reopen ).with( on do | mock | mock.mock_name == 'CHILD_STDOUT' end ).once
    flexmock( STDERR ).should_receive( :reopen ).with( on do | mock | mock.mock_name == 'CHILD_STDERR' end ).once

    # close_end_of @child_pipe
    child_stdin.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stdin.should_receive( :close ).with_no_args.once.ordered
    child_stdout.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stdout.should_receive( :close ).with_no_args.once.ordered
    child_stderr.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stderr.should_receive( :close ).with_no_args.once.ordered

    flexmock( ENV ).should_receive( :[]= ).with( 'TEST_ENV_NAME', 'TEST_ENV_VALUE' ).once
    kernel_class_mock.should_receive( :exec ).with( 'COMMAND', 'ARG1', 'ARG2' ).once

    # Parent Process ############################################################

    # close_end_of @child_pipe
    child_stdin.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stdin.should_receive( :close ).with_no_args.once.ordered
    child_stdout.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stdout.should_receive( :close ).with_no_args.once.ordered
    child_stderr.should_receive( :closed? ).with_no_args.once.ordered.and_return( false )
    child_stderr.should_receive( :close ).with_no_args.once.ordered

    tochild.should_receive( :sync= ).with( true ).once.ordered

    return [ tochild, fromchild, childerr ]
  end


  def dummy_env
    return { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
  end


  def dummy_pid
    return 'DUMMY_PID'
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
