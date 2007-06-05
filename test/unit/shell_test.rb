#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class ShellTest < Test::Unit::TestCase
  def test_on_exit_block_should_be_called
    fromchild_mock = mock( 'FROMCHILD', :gets => nil )
    childerr_mock = mock( 'CHILDERR', :gets => nil )

    process_mock = mock( 'PROCESS' )
    process_mock.expects( :popen3 ).yields( nil, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    Popen3::Shell.open do | shell |
      shell.on_exit do
        raise 'on_exit block successfully called'
      end

      assert_raises 'on_exit block successfully called' do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  def test_on_success_block_should_be_called
    fromchild_mock = mock( 'FROMCHILD', :gets => nil )
    childerr_mock = mock( 'CHILDERR', :gets => nil )

    process_mock = mock()
    process_mock.expects( :popen3 ).yields( nil, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    Popen3::Shell.open do | shell |
      shell.instance_variable_set( :@child_status, mock( 'CHILD_STATUS', :exitstatus => 0) )

      shell.on_success do
        raise 'on_success block successfully called'
      end

      assert_raises 'on_success block successfully called' do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  def test_on_failure_block_should_be_called
    fromchild_mock = mock( 'FROMCHILD', :gets => nil )
    childerr_mock = mock( 'CHILDERR', :gets => nil )

    process_mock = mock( 'PROCESS' )
    process_mock.expects( :popen3 ).yields( nil, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    Popen3::Shell.open do | shell |
      shell.instance_variable_set( :@child_status, mock( 'CHILD_STATUS', :exitstatus => 1 ) )

      shell.on_failure do
        raise 'on_failure block successfully called'
      end

      assert_raises 'on_failure block successfully called' do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  def test_puts
    tochild_mock = mock( 'TOCHILD' )
    tochild_mock.expects( :puts ).times( 2 ).returns( 'PUTS1', 'PUTS2' )
    fromchild_mock = mock( 'FROMCHILD', :gets => nil )
    childerr_mock = mock( 'CHILDERR', :gets => nil )

    process_mock = mock( 'PROCESS' )
    process_mock.expects( :popen3 ).yields( tochild_mock, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    Popen3::Shell.open do | shell |
      shell.exec dummy_env, *dummy_command
      shell.puts 'PUTS1'
      shell.puts 'PUTS2'
    end
  end


  def test_on_stdout
    fromchild_mock = mock( 'FROMCHILD' )
    fromchild_mock.expects( :gets ).times( 3 ).returns( 'FROMCHILD_LINE1', 'FROMCHILD_LINE2', nil  )
    childerr_mock = mock( 'CHILDERR', :gets => nil )

    process_mock = mock( 'PROCESS' )
    process_mock.expects( :popen3 ).yields( nil, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    ncall_on_stdout = 0
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        ncall_on_stdout += 1
        assert_equal "FROMCHILD_LINE#{ ncall_on_stdout }", line
      end
      shell.exec dummy_env, *dummy_command
    end

    assert_equal 2, ncall_on_stdout
  end


  def test_on_stderr
    fromchild_mock = mock( 'FROMCHILD', :gets => nil )
    childerr_mock = mock( 'CHILDERR' )
    childerr_mock.expects( :gets ).times( 3 ).returns( 'CHILDERR_LINE1', 'CHILDERR_LINE2', nil  )

    process_mock = mock( 'PROCESS' )
    process_mock.expects( :popen3 ).yields( nil, fromchild_mock, childerr_mock )
    process_mock.expects( :wait )
    Popen3::Popen3.expects( :new ).returns( process_mock )

    ncall_on_stderr = 0
    Popen3::Shell.open do | shell |
      shell.on_stderr do | line |
        ncall_on_stderr += 1
        assert_equal "CHILDERR_LINE#{ ncall_on_stderr }", line
      end
      shell.exec dummy_env, *dummy_command
    end

    assert_equal 2, ncall_on_stderr
  end


  def test_sh_exec_should___success___
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    Lucie::Log.expects( :error ).times( 1 ).with( 'STDERR' )
    shell_mock.expects( :on_failure )
    shell_mock.expects( :exec ).times( 1 ).with( { 'LC_ALL' => 'C' }, 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
    Popen3::Shell.expects( :open ).times( 1 ).yields( shell_mock ).returns( 'SUCCESS' )

    assert_equal 'SUCCESS', Kernel.sh_exec( 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
  end


  ##############################################################################
  # Test helper methods
  ##############################################################################


  private


  def dummy_env
    return { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
  end


  def dummy_command
    return [ 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
