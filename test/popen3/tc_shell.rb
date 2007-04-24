#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'popen3/shell'
require 'test/unit'


class TC_Shell < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    Popen3::Shell.reset
  end


  def teardown
    Popen3::Shell.reset
    Kernel.load_shell Popen3::Shell
  end


  def test_logger
    shell = Popen3::Shell.new

    assert_equal Lucie, Popen3::Shell.logger

    Popen3::Shell.logger = 'DUMMY_LOGGER_1'
    assert_equal 'DUMMY_LOGGER_1', Popen3::Shell.logger

    Popen3::Shell.logging_off
    assert_nil Popen3::Shell.logger
    assert_nil shell.logger

    shell.logger = 'DUMMY_LOGGER_2'
    assert_equal 'DUMMY_LOGGER_2', shell.logger

    shell.logging_off
    assert_nil Popen3::Shell.logger
    assert_nil shell.logger

    shell.logging_on
    assert_equal 'DUMMY_LOGGER_2', Popen3::Shell.logger
    assert_equal 'DUMMY_LOGGER_2', shell.logger
  end


  class ExternalCommandOnExit < ::Exception
  end


  def test_on_exit
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call nil, fromchild_mock, childerr_mock
        end
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Popen3::Shell.load_popen3 popen3_class_mock

    Popen3::Shell.open do | shell |
      shell.on_exit do
        raise ExternalCommandOnExit
      end

      assert_raises( ExternalCommandOnExit ) do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  class ExternalCommandExecSuccess < ::Exception
  end


  def test_on_success
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call nil, fromchild_mock, childerr_mock
        end
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Popen3::Shell.load_popen3 popen3_class_mock

    Popen3::Shell.open do | shell |
      flexmock( 'PROCESS::STATUS' ) do | mock |
        mock.should_receive( :exitstatus ).once.ordered.and_return( 0 )
        shell.instance_variable_set( :@child_status, mock )
      end
      shell.on_success do
        raise ExternalCommandExecSuccess
      end

      assert_raises( ExternalCommandExecSuccess ) do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  class ExternalCommandExecFailure < ::Exception
  end


  def test_on_failure
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call nil, fromchild_mock, childerr_mock
        end
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Popen3::Shell.load_popen3 popen3_class_mock

    Popen3::Shell.open do | shell |
      flexmock( 'PROCESS::STATUS' ) do | mock |
        mock.should_receive( :exitstatus ).once.ordered.and_return( 1 )
        shell.instance_variable_set( :@child_status, mock )
      end
      shell.on_failure do
        raise ExternalCommandExecFailure
      end

      assert_raises( ExternalCommandExecFailure ) do
        shell.exec dummy_env, *dummy_command
      end
    end
  end


  def test_puts
    tochild_mock = flexmock( 'TOCHILD' )
    tochild_mock.should_receive( :puts ).times( 2 ).ordered.and_return( 'PUTS1', 'PUTS2' )

    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | popen3 |
        popen3.should_receive( :logger= ).once.ordered
        popen3.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call tochild_mock, fromchild_mock, childerr_mock
        end
        popen3.should_receive( :wait ).with_no_args.once.ordered
      end
    end
    Popen3::Shell.load_popen3 popen3_class_mock

    Popen3::Shell.open do | shell |
      shell.exec dummy_env, *dummy_command
      shell.puts 'PUTS1'
      shell.puts 'PUTS2'
    end
  end


  def test_on_stdout
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call nil, fromchild_mock, childerr_mock
        end
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Popen3::Shell.load_popen3 popen3_class_mock

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
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered.and_return do | block |
          block.call nil, fromchild_mock, childerr_mock
        end
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Popen3::Shell.load_popen3 popen3_class_mock

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


  def test_abbreviation
    popen3_class_mock = flexmock( 'POPEN3_CLASS' )
    popen3_class_mock.should_receive( :new ).once.and_return do
      flexmock( 'POPEN3' ) do | mock |
        mock.should_receive( :logger= ).once.ordered
        mock.should_receive( :popen3 ).with( Proc ).once.ordered
        mock.should_receive( :wait ).with_no_args.once.ordered
      end
    end

    Kernel.load_shell Popen3::Shell
    Popen3::Shell.load_popen3 popen3_class_mock

    assert_kind_of Popen3::Shell, Kernel.sh_exec( 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' )
  end


  ##############################################################################
  # Test helper methods
  ##############################################################################


  def fromchild_mock
    return flexmock( 'FROMCHILD' ) do | mock |
      mock.should_receive( :gets ).times( 3 ).ordered.and_return( 'FROMCHILD_LINE1', 'FROMCHILD_LINE2', nil )
    end
  end


  def childerr_mock
    return flexmock( 'CHILDERR' ) do | mock |
      mock.should_receive( :gets ).times( 3 ).ordered.and_return( 'CHILDERR_LINE1', 'CHILDERR_LINE2', nil )
    end
  end


  def dummy_env
    return { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
  end


  def dummy_command
    return [ 'TEST_COMMAND', 'TEST_ARG1', 'TEST_ARG2' ]
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
