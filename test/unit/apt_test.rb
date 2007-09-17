require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/popen3/apt'


class AptTest < Test::Unit::TestCase
  def test_child_status
    shell = Object.new
    shell.stubs( :child_status ).returns( 'CHILD_STATUS' )
    Popen3::Shell.expects( :open ).returns( shell )

    assert_equal 'CHILD_STATUS', Popen3::Apt.get( '-y dist-upgrade' ).child_status
  end


  def test_abbrev_apt_get
    Popen3::Apt.expects( :get ).with( '-y dist-upgrade', { :root => '/ROOT' } )
    AptGet.apt '-y dist-upgrade', { :root => '/ROOT' }
  end


  def test_apt_get___success___
    apt = Object.new
    apt.expects( :get ).with( '-y dist-upgrade' ).times( 1 )
    Popen3::Apt.stubs( :new ).with( { :root => '/ROOT' } ).returns( apt )

    Popen3::Apt.get( '-y dist-upgrade', { :root => '/ROOT' } )
  end


  def test_apt_get___fail___
    Popen3::Shell.expects( :open ).yields( fail_shell_stub )

    assert_raises( "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get -y dist-upgrade' failed!" ) do
      Popen3::Apt.get '-y dist-upgrade'
    end
  end


  def test_abbrev_apt_clean
    Popen3::Apt.expects( :clean ).with( { :root => '/ROOT' } )
    AptGet.clean :root => '/ROOT'
  end


  def test_apt_clean___success___
    apt = Object.new
    apt.expects( :clean ).times( 1 )
    Popen3::Apt.stubs( :new ).with( { :root => '/ROOT' } ).returns( apt )

    Popen3::Apt.clean( { :root => '/ROOT' } )
  end


  def test_apt_clean___fail___
    Popen3::Shell.expects( :open ).yields( fail_shell_stub )

    assert_raises( "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get clean' failed!" ) do
      Popen3::Apt.clean
    end
  end


  def test_abbrev_apt_update
    Popen3::Apt.expects( :update ).with( { :root => '/ROOT' } )
    AptGet.update :root => '/ROOT'
  end


  def test_apt_update___success___
    apt = Object.new
    apt.expects( :update ).times( 1 )
    Popen3::Apt.stubs( :new ).with( { :root => '/ROOT' } ).returns( apt )

    Popen3::Apt.update( { :root => '/ROOT' } )
  end


  def test_apt_update___fail___
    Popen3::Shell.expects( :open ).yields( fail_shell_stub )

    assert_raises( "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get update' failed!" ) do
      Popen3::Apt.update
    end
  end


  def test_abbrev_apt_check
    Popen3::Apt.expects( :check ).with( { :root => '/ROOT' } )
    AptGet.check :root => '/ROOT'
  end


  def test_apt_check___success___
    apt = Object.new
    apt.expects( :check ).times( 1 )
    Popen3::Apt.stubs( :new ).with( { :root => '/ROOT' } ).returns( apt )

    Popen3::Apt.check( { :root => '/ROOT' } )
  end


  def test_apt_check___fail___
    Popen3::Shell.expects( :open ).yields( fail_shell_stub )

    assert_raises( "ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'apt-get check' failed!" ) do
      Popen3::Apt.check
    end
  end


  def test_apt_get_with_no_option_execs_the_right_command
    shell = success_shell_mock
    shell.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell )

    Popen3::Apt.get( '-y dist-upgrade' )
  end


  def test_apt_get_with_root_option_execs_the_right_command
    shell = success_shell_mock
    shell.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'chroot', '/ROOT', 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell )

    Popen3::Apt.get( '-y dist-upgrade', :root => '/ROOT' )
  end


  def test_apt_get_with_env_option_execs_the_right_command
    shell = success_shell_mock
    shell.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive', 'ENV_NAME' => 'ENV_VALUE' }, 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell )

    Popen3::Apt.get( '-y dist-upgrade', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
  end


  def test_stdout_and_stderr_logging
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


  private


  def success_shell_mock
    shell = mock( 'SHELL' )
    shell.expects( :on_stdout )
    shell.expects( :on_stderr )
    shell.expects( :on_failure )
    return shell
  end


  def fail_shell_stub
    shell = Object.new
    shell.stubs( :on_stdout )
    shell.stubs( :on_stderr )
    shell.stubs( :on_failure ).yields
    return shell
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
