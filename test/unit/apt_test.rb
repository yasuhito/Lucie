#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class AptTest < Test::Unit::TestCase
  def setup
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout )
    shell_mock.expects( :on_stderr )
    shell_mock.expects( :exec )
    shell_mock.expects( :child_status ).returns( 'CHILD_STATUS' )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )
  end


  def test_apt_get_nooption
    result = Popen3::Apt.get( '-y dist-upgrade' )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_apt_get_withoption
    result = Popen3::Apt.get( '-y dist-upgrade', :root => '/ROOT', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  ##############################################################################
  # apt-get check
  ##############################################################################


  def test_check_nooption
    result = Popen3::Apt.check
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_check_withoption
    result = Popen3::Apt.check( :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_check_abbreviation_nooption
    result = AptGet.check
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_check_abbreviation_withoption
    result = AptGet.check( :root => '/ROOT', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  ##############################################################################
  # apt-get clean
  ##############################################################################


  def test_clean_nooption
    result = Popen3::Apt.clean
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_clean_withoption
    result = Popen3::Apt.clean( :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_clean_abbreviation_nooption
    result = AptGet.clean
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_clean_abbreviation_withoption
    result = AptGet.clean( :root => '/ROOT', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  ##############################################################################
  # apt-get update
  ##############################################################################


  def test_update_nooption
    result = Popen3::Apt.update
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_update_withoption
    result = Popen3::Apt.update( :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_update_abbreviation_nooption
    result = AptGet.update
    assert_equal 'CHILD_STATUS', result.child_status
  end


  def test_update_abbreviation_withoption
    result = AptGet.update( :root => '/ROOT', :env => { 'ENV_NAME' => 'ENV_VALUE' } )
    assert_equal 'CHILD_STATUS', result.child_status
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
