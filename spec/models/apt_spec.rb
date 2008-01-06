require File.dirname( __FILE__ ) + '/../spec_helper'
require 'lib/popen3/apt'


describe 'All apt', :shared => true do
  before( :each ) do
    @fail_shell = Object.new
    @fail_shell.stubs( :on_stdout )
    @fail_shell.stubs( :on_stderr )
    @fail_shell.stubs( :on_failure ).yields

    @success_shell = Object.new
    @success_shell.stubs( :on_stdout )
    @success_shell.stubs( :on_stderr )
    @success_shell.stubs( :on_failure )
  end
end


describe Popen3::Apt, 'when executing self.clean' do
  it_should_behave_like 'All apt'


  it 'should success' do
    apt = Object.new
    apt.expects( :clean ).times( 1 )
    Popen3::Apt.stubs( :new ).with( :root => '/ROOT' ).returns( apt )

    Popen3::Apt.clean :root => '/ROOT'
  end


  it 'should allow AptGet.clean' do
    Popen3::Apt.expects( :clean ).with( :root => '/ROOT' )

    AptGet.clean :root => '/ROOT'
  end


  it 'should raise if failed' do
    Popen3::Shell.stubs( :open ).yields( @fail_shell )

    lambda do
      Popen3::Apt.clean
    end.should raise_error( RuntimeError, "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get clean' failed!" )
  end
end


describe Popen3::Apt, 'when executing self.update' do
  it_should_behave_like 'All apt'


  it 'should success' do
    apt = Object.new
    apt.expects( :update ).times( 1 )
    Popen3::Apt.stubs( :new ).with( :root => '/ROOT' ).returns( apt )

    Popen3::Apt.update :root => '/ROOT'
  end


  it 'should allow AptGet.update' do
    Popen3::Apt.expects( :update ).with( :root => '/ROOT' )

    AptGet.update :root => '/ROOT'
  end


  it 'should raise if failed' do
    Popen3::Shell.stubs( :open ).yields( @fail_shell )

    lambda do
      Popen3::Apt.update
    end.should raise_error( RuntimeError, "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get update' failed!" )
  end
end


describe Popen3::Apt, 'when executing self.check' do
  it_should_behave_like 'All apt'


  it 'should success apt check' do
    apt = Object.new
    apt.expects( :check ).times( 1 )
    Popen3::Apt.stubs( :new ).with( :root => '/ROOT' ).returns( apt )

    Popen3::Apt.check :root => '/ROOT'
  end


  it 'should allow AptGet.check' do
    Popen3::Apt.expects( :check ).with( :root => '/ROOT' )

    AptGet.check :root => '/ROOT'
  end


  it 'should raise if failed' do
    Popen3::Shell.stubs( :open ).yields( @fail_shell )

    lambda do
      Popen3::Apt.check
    end.should raise_error( RuntimeError, "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get check' failed!" )
  end
end


describe Popen3::Apt, 'when executing self.get' do
  it_should_behave_like 'All apt'


  it 'should success if subprocess apt-get succeeded' do
    apt = Object.new
    apt.expects( :get ).with( '-y dist-upgrade' ).times( 1 )
    Popen3::Apt.stubs( :new ).with( :root => '/ROOT' ).returns( apt )

    Popen3::Apt.get( '-y dist-upgrade', :root => '/ROOT' )
  end


  it 'should allow Apt.get' do
    Popen3::Apt.expects( :get ).with( '-y dist-upgrade',  :root => '/ROOT' )

    AptGet.apt '-y dist-upgrade', :root => '/ROOT'
  end


  it 'should raise if failed' do
    Popen3::Shell.expects( :open ).yields( @fail_shell )

    lambda do
      Popen3::Apt.get '-y dist-upgrade'
    end.should raise_error( RuntimeError, "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get -y dist-upgrade' failed!" )
  end


  it 'should return child status' do
    shell = Object.new
    shell.stubs( :child_status ).returns( 'CHILD_STATUS' )
    Popen3::Shell.stubs( :open ).returns( shell )

    Popen3::Apt.get( '-y dist-upgrade' ).child_status.should == 'CHILD_STATUS'
  end


  it 'should execute right command' do
    Popen3::Shell.stubs( :open ).yields( @success_shell )

    @success_shell.expects( :exec ).with( 'apt-get -y dist-upgrade', { :env => { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' } } )

    Popen3::Apt.get( '-y dist-upgrade' )
  end


  it 'should execute right command if option specified' do
    Popen3::Shell.stubs( :open ).yields( @success_shell )

    @success_shell.expects( :exec ).with( 'chroot /ROOT apt-get -y dist-upgrade', { :env => { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' } } )

    Popen3::Apt.get( '-y dist-upgrade', :root => '/ROOT' )
  end


  it 'should execute right command if env specified' do
    Popen3::Shell.stubs( :open ).yields( @success_shell )

    @success_shell.expects( :exec ).with( 'apt-get -y dist-upgrade', { :env => { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive', 'ENV_NAME' => 'ENV_VALUE' } } )

    Popen3::Apt.get( '-y dist-upgrade', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
  end


  it 'should log stdout and stderr' do
    shell_mock = mock( 'SHELL' )
    Lucie::Log.expects( :debug ).times( 1 ).with( 'STDOUT' )
    shell_mock.expects( :on_stdout ).yields( 'STDOUT' )
    Lucie::Log.expects( :debug ).times( 1 ).with( 'STDERR' )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.get( '-y dist-upgrade' )
  end
end
