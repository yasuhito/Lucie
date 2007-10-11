require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'All Debootstrap', :shared => true do
  def silent_shell
    shell = Object.new
    shell.stubs( :on_stdout )
    shell.stubs( :on_stderr )
    shell.stubs( :on_failure )
    shell.stubs( :exec )
    return shell
  end
end


describe Debootstrap, 'when debootstrap installed' do
  it 'should determine debootstrap version' do
    shell = Object.new
    shell.stubs( :on_stdout ).yields( 'ii  debootstrap    0.2.45-0.2     Bootstrap a basic Debian system' )
    shell.stubs( :exec )
    Popen3::Shell.stubs( :open ).yields( shell )

    Debootstrap.VERSION.should == '0.2.45-0.2'
  end
end


describe Debootstrap, 'when debootstrap not installed' do
  it 'should not be able to determine debootstrap version' do
    shell = Object.new
    shell.stubs( :on_stdout )
    shell.stubs( :exec )
    Popen3::Shell.stubs( :open ).yields( shell )

    lambda do
      Debootstrap.VERSION
    end.should raise_error( RuntimeError, 'Cannot determine debootstrap version.' )
  end
end


describe Debootstrap, 'when executing debootstrap' do
  it_should_behave_like 'All Debootstrap'


  it 'should successfully run debootstrap' do
    shell = silent_shell
    shell.stubs( :child_status ).returns( 'CHILD_STATUS' )

    Popen3::Shell.expects( :open ).yields( shell ).returns( shell )

    result = Debootstrap.start do | option |
      option.arch = 'i386'
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
    end

    lambda do
      result.child_status.should == 'CHILD_STATUS'
    end.should_not raise_error
  end


  it 'should fail running debootstrap' do
    shell = silent_shell
    shell.stubs( :exec ).raises( RuntimeError, 'ERROR_MESSAGE' )

    Popen3::Shell.expects( :open ).yields( shell ).returns( shell )

    lambda do
      Debootstrap.start do | option |
        option.arch = 'i386'
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'ERROR_MESSAGE' )
  end
end


describe Debootstrap, 'when missing mandatory debootstrap options' do
  it_should_behave_like 'All Debootstrap'


  before( :each ) do
    Popen3::Shell.stubs( :open ).yields( silent_shell ).returns( silent_shell )
  end


  it 'should fail if mandatory arch option not set' do
    lambda do
      Debootstrap.start do | option |
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'arch option is a mandatory' )
  end


  it 'should fail if mandatory suite option not set' do
    lambda do
      Debootstrap.start do | option |
        option.arch = 'i386'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'suite option is a mandatory' )
  end


  it 'should fail if mandatory target option not set' do
    lambda do
      Debootstrap.start do | option |
        option.arch = 'i386'
        option.suite = 'etch'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'target option is a mandatory' )
  end


  it 'should fail if mandatory mirror option not set' do
    lambda do
      Debootstrap.start do | option |
        option.arch = 'i386'
        option.suite = 'etch'
        option.target = '/TMP'
      end
    end.should raise_error( RuntimeError, 'mirror option is a mandatory' )
  end
end


describe Debootstrap, 'when logging debootstrap outputs' do
  it 'should log stdout' do
    shell = Object.new
    shell.stubs( :on_stderr )
    shell.stubs( :on_failure )
    shell.stubs( :exec )

    shell.expects( :on_stdout ).yields( 'STDOUT' )
    Lucie::Log.expects( :debug ).with( 'STDOUT' )

    Popen3::Shell.expects( :open ).yields( shell ).returns( shell )

    Debootstrap.start do | option |
      option.arch = 'i386'
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
    end
  end


  it 'should log stderr' do
    shell = Object.new
    shell.stubs( :on_stdout )
    shell.stubs( :on_failure )
    shell.stubs( :exec )

    shell.expects( :on_stderr ).yields( 'STDERR' )
    Lucie::Log.expects( :error ).with( 'STDERR' )

    Popen3::Shell.expects( :open ).yields( shell ).returns( shell )

    Debootstrap.start do | option |
      option.arch = 'i386'
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
    end
  end


  it 'should raise last error message on failure' do
    shell = Object.new
    shell.stubs( :on_stdout )
    shell.stubs( :exec )

    shell.expects( :on_stderr ).yields( 'STDERR' )
    Lucie::Log.expects( :error ).with( 'STDERR' )

    shell.expects( :on_failure ).yields

    Popen3::Shell.expects( :open ).yields( shell ).returns( shell )

    lambda do
      Debootstrap.start do | option |
        option.arch = 'i386'
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      end
    end.should raise_error( RuntimeError, 'STDERR' )
  end
end
