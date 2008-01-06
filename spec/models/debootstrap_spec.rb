require File.dirname( __FILE__ ) + '/../spec_helper'


describe Debootstrap, 'when calling Debootstrap::VERSION' do
  before( :each ) do
    @shell = Object.new
    @shell.stubs( :exec )
    Popen3::Shell.stubs( :open ).yields( @shell )
  end


  it 'should return debootstrap version if debootstrap is installed' do
    @shell.stubs( :on_stdout ).yields( 'ii  debootstrap    0.2.45-0.2     Bootstrap a basic Debian system' )
    @shell.stubs( :on_failure )

    Debootstrap.VERSION.should == '0.2.45-0.2'
  end


  it 'should not return debootstrap version if debootstrap is not installed' do
    @shell.stubs( :on_stdout )
    @shell.stubs( :on_failure )

    lambda do
      Debootstrap.VERSION
    end.should raise_error( RuntimeError, 'Cannot determine debootstrap version.' )
  end


  it 'should not return debootstrap version if dpkg -l failed' do
    @shell.stubs( :on_stdout )
    @shell.expects( :on_failure ).yields

    lambda do
      Debootstrap.VERSION
    end.should raise_error( RuntimeError, 'Cannot determine debootstrap version.' )
  end
end


describe Debootstrap, 'when calling Debootstrap.start' do
  before( :each ) do | each |
    @shell = Object.new
    @shell.stubs( :on_stdout )
    @shell.stubs( :on_stderr )
    @shell.stubs( :on_failure )
    @shell.stubs( :exec )

    Popen3::Shell.stubs( :open ).yields( @shell ).returns( @shell )
  end


  it 'should successfully run debootstrap if all mandatory options are set' do
    lambda do
      Debootstrap.start do | option |
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should_not raise_error
  end


  it 'should fail if mandatory suite option is not set' do
    lambda do
      Debootstrap.start do | option |
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'suite option is a mandatory' )
  end


  it 'should fail if mandatory target option is not set' do
    lambda do
      Debootstrap.start do | option |
        option.suite = 'etch'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'target option is a mandatory' )
  end


  it 'should fail if mandatory mirror option is not set' do
    lambda do
      Debootstrap.start do | option |
        option.suite = 'etch'
        option.target = '/TMP'
      end
    end.should raise_error( RuntimeError, 'mirror option is a mandatory' )
  end
end


describe 'All Debootstrap', :shared => true do
  before( :each ) do
    @shell = Object.new
    Popen3::Shell.expects( :open ).yields( @shell ).returns( @shell )

    @debootstrap = lambda do
      Debootstrap.start do | option |
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end
  end
end


describe Debootstrap, 'when logging outputs' do
  it_should_behave_like 'All Debootstrap'


  before( :each ) do
    @shell.stubs( :exec )
    @shell.stubs( :on_failure )
  end


  it 'should log stdout' do
    @shell.stubs( :on_stderr )

    @shell.expects( :on_stdout ).yields( 'STDOUT' )
    Lucie::Log.expects( :debug ).with( 'STDOUT' )

    @debootstrap.call
  end


  it 'should log stderr' do
    @shell.stubs( :on_stdout )

    @shell.expects( :on_stderr ).yields( 'STDERR' )
    Lucie::Log.expects( :error ).with( 'STDERR' )

    @debootstrap.call
  end
end


describe Debootstrap, 'when failed to execute' do
  it_should_behave_like 'All Debootstrap'


  it "should Log.error a line starts with 'E:'" do
    @shell.stubs( :on_stderr )
    @shell.stubs( :on_failure )
    @shell.stubs( :exec )

    @shell.expects( :on_stdout ).yields( 'E: ERROR_MESSAGE' )
    Lucie::Log.expects( :error ).with( 'E: ERROR_MESSAGE' )

    @debootstrap.call
  end


  it 'should raise last error message on failure' do
    @shell.stubs( :on_stdout )
    Lucie::Log.stubs( :error )

    @shell.expects( :on_stderr ).yields( 'LAST_ERROR_MESSAGE' )
    @shell.expects( :on_failure ).yields

    @debootstrap.should raise_error( RuntimeError, 'LAST_ERROR_MESSAGE' )
  end
end
