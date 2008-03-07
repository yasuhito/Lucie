require File.dirname( __FILE__ ) + '/../spec_helper'


describe Popen3::Shell, 'when executing command using Kernel.sh_exec' do
  it 'should call all the hooks when command succeeds' do
    STDOUT.stubs( :puts )
    STDERR.stubs( :puts )

    # expects
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout ).yields( 'STDOUT' )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    shell_mock.expects( :on_failure )
    shell_mock.expects( :exec ).times( 1 ).with( 'TEST_COMMAND TEST_ARG1 TEST_ARG2', { :env => { 'LC_ALL' => 'C' } } )
    Popen3::Shell.expects( :open ).times( 1 ).yields( shell_mock ).returns( 'SUCCESS' )

    # when
    Kernel.sh_exec( 'TEST_COMMAND TEST_ARG1 TEST_ARG2' ).should == 'SUCCESS'

    # then
    verify_mocks
  end


  it 'should call all the hooks when command fails' do
    STDOUT.stubs( :puts )
    STDERR.stubs( :puts )
    
    # expects
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout ).yields( 'STDOUT' )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    shell_mock.expects( :on_failure ).yields
    Popen3::Shell.expects( :open ).times( 1 ).yields( shell_mock ).returns( 'FAILURE' )

    # when
    lambda do
      Kernel.sh_exec( 'TEST_COMMAND TEST_ARG1 TEST_ARG2' ).should == 'FAILURE'
    end.should raise_error( RuntimeError, %(Command "TEST_COMMAND TEST_ARG1 TEST_ARG2" failed.\nSTDERR) )

    # then
    verify_mocks
  end
end


describe Popen3::Shell, 'when executing command using Popen3::Shell.open' do
  before( :each ) do
    Popen3::Popen3.any_instance.stubs( :popen3 )
    Popen3::Popen3.any_instance.stubs( :wait )

    @dummy_command = 'TEST_COMMAND TEST_ARG1 TEST_ARG2'
    @dummy_option = { 'TEST_OPTION_KEY' => 'TEST_OPTION_VALUE' }
  end


  it 'should call on_exit when command exitted' do
    Popen3::Shell.open do | shell |
      # given
      shell.on_exit do
        raise 'on_exit BLOCK SUCCESSFULLY CALLED'
      end

      lambda do
        # when
        shell.exec @dummy_command, @dummy_option

        # then
      end.should raise_error( RuntimeError, 'on_exit BLOCK SUCCESSFULLY CALLED' )
    end
  end


  it 'should call on_success when command succeseeded' do
    Popen3::Shell.open do | shell |
      # given
      shell.stubs( :child_status ).returns( mock( 'CHILD_STATUS', :exitstatus => 0 ) )
      shell.on_success do
        raise 'on_success BLOCK SUCCESSFULLY CALLED'
      end

      lambda do
        # when
        shell.exec @dummy_command, @dummy_option

        # then
      end.should raise_error( RuntimeError, 'on_success BLOCK SUCCESSFULLY CALLED' )
    end
  end


  it 'should call on_failure when command failed' do
    Popen3::Shell.open do | shell |
      # given
      shell.stubs( :child_status ).returns( mock( 'CHILD_STATUS', :exitstatus => 1 ) )
      shell.on_failure do
        raise 'on_failure BLOCK SUCCESSFULLY CALLED'
      end

      lambda do
        # when
        shell.exec @dummy_command, @dummy_option

        # then
      end.should raise_error( RuntimeError, 'on_failure BLOCK SUCCESSFULLY CALLED' )
    end
  end
end


describe Popen3::Shell, 'when doing IOs with subprocess' do
  before( :each ) do
    Popen3::Popen3.any_instance.stubs( :wait )

    @dummy_command = 'TEST_COMMAND TEST_ARG1 TEST_ARG2'
    @dummy_option = { 'TEST_OPTION_KEY' => 'TEST_OPTION_VALUE' }
  end


  it 'should pass inputs to subprocess when Popen3::Shell#puts called' do
    # expects
    tochild_mock = mock( 'TOCHILD' )
    tochild_mock.expects( :puts ).times( 2 ).returns( 'PUTS1', 'PUTS2' )
    Popen3::Popen3.any_instance.stubs( :popen3 ).yields( tochild_mock, mock( 'FROMCHILD', :gets => nil ), mock( 'CHILDERR', :gets => nil ) )

    Popen3::Shell.open do | shell |
      shell.stubs( :child_status ).returns( mock( 'CHILD_STATUS', :exitstatus => 0 ) )

      # when
      shell.exec @dummy_command, @dummy_option
      shell.puts 'PUTS1'
      shell.puts 'PUTS2'
    end

    # then
    verify_mocks
  end


  it 'should call on_stdout when subprocess outputs to stdout' do
    # expects
    fromchild_mock = mock( 'FROMCHILD' )
    fromchild_mock.expects( :gets ).times( 3 ).returns( 'FROMCHILD_LINE1', 'FROMCHILD_LINE2', nil  )
    Popen3::Popen3.any_instance.stubs( :popen3 ).yields( nil, fromchild_mock, mock( 'CHILDERR', :gets => nil ) )

    ncall_on_stdout = 0
    Popen3::Shell.open do | shell |
      shell.stubs( :child_status ).returns( mock( 'CHILD_STATUS', :exitstatus => 0 ) )

      # when
      shell.on_stdout do | line |
        ncall_on_stdout += 1
         line.should == "FROMCHILD_LINE#{ ncall_on_stdout }"
      end
      shell.exec @dummy_command, @dummy_option
    end

    # then
    ncall_on_stdout.should == 2
    verify_mocks
  end


  it 'should call on_stderr when subprocess outputs to stderr' do
    # expects
    childerr_mock = mock( 'CHILDERR' )
    childerr_mock.expects( :gets ).times( 3 ).returns( 'CHILDERR_LINE1', 'CHILDERR_LINE2', nil  )
    Popen3::Popen3.any_instance.stubs( :popen3 ).yields( nil, mock( 'FROMCHILD', :gets => nil ), childerr_mock )

    ncall_on_stderr = 0
    Popen3::Shell.open do | shell |
      shell.stubs( :child_status ).returns( mock( 'CHILD_STATUS', :exitstatus => 0 ) )

      # when
      shell.on_stderr do | line |
        ncall_on_stderr += 1
        assert_equal "CHILDERR_LINE#{ ncall_on_stderr }", line
      end
      shell.exec @dummy_command, @dummy_option
    end

    # then
    assert_equal 2, ncall_on_stderr
    verify_mocks
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
