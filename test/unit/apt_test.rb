#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class AptTest < Test::Unit::TestCase
  def test_apt_get_should___success___
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec )
    shell_mock.expects( :child_status ).returns( 'CHILD_STATUS' )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    result = Popen3::Apt.get( '-y dist-upgrade' )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_apt_get_should___fail___
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure ).yields

    Popen3::Shell.expects( :open ).yields( shell_mock )

    assert_raises( RuntimeError ) do
      Popen3::Apt.get '-y dist-upgrade'
    end
  end


  def test_apt_get_with_no_option_execs_the_right_command
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.get( '-y dist-upgrade' )
  end


  def test_apt_get_with_root_option_execs_the_right_command
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'chroot', '/ROOT', 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.get( '-y dist-upgrade', :root => '/ROOT' )
  end


  def test_apt_get_with_env_option_execs_the_right_command
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive', 'ENV_NAME' => 'ENV_VALUE' }, 'apt-get', '-y', 'dist-upgrade' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.get( '-y dist-upgrade', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
  end


  def test_apt_check_with_no_option_execs_the_right_command
    # test Popen3::Apt#check
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'check' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.check

    # test AptGet#check
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'check' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    AptGet.check
  end


  def test_apt_clean_with_no_option_execs_the_right_command
    # test Popen3::Apt#clean
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'clean' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.clean

    # test AptGet#clean
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'clean' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    AptGet.clean
  end


  def test_apt_update_with_no_option_execs_the_right_command
    # test Popen3::Apt#update
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'update' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.update

    # test AptGet#update
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }, 'apt-get', 'update' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    AptGet.update
  end


  def test_stdout_and_stderr_logging
    shell_mock = mock( 'SHELL' )
    Lucie::Log.expects( :debug ).times( 1 ).with( 'STDOUT' )
    shell_mock.expects( :on_stdout ).yields( 'STDOUT' )
    Lucie::Log.expects( :error ).times( 1 ).with( 'STDERR' )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    shell_mock.expects( :on_failure )

    shell_mock.expects( :exec )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    Popen3::Apt.get( '-y dist-upgrade' )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
