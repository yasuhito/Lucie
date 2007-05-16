#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class InstallerConfigTrackerTest < Test::Unit::TestCase
  include FileSandbox


  def setup
    @sandbox = Sandbox.new
    @tracker = InstallerConfigTracker.new( @sandbox.root )
  end


  def teardown
    @sandbox.clean_up
  end


  def test_config_modifications_should_return_true_if_local_config_file_is_created
    @sandbox.new :file => 'installer_config.rb'
    assert @tracker.config_modified?
  end


  def test_config_modifications_should_return_true_if_central_config_file_is_created
    @sandbox.new :file => 'work/installer_config.rb'
    assert @tracker.config_modified?
  end


  def test_config_modifications_should_return_true_if_central_config_file_is_modified
    @tracker.central_mtime = 1.second.ago
    @sandbox.new :file => 'work/installer_config.rb'
    assert @tracker.config_modified?
  end


  def test_config_modifications_should_return_true_if_local_config_file_is_modified
    @tracker.local_mtime = 1.second.ago
    @sandbox.new :file => 'installer_config.rb'
    assert @tracker.config_modified?
  end


  def test_config_modifications_should_return_false_if_config_files_not_modified
    assert_false @tracker.config_modified?

    @sandbox.new :file => 'installer_config.rb'
    @sandbox.new :file => 'work/installer_config.rb'

    assert @tracker.config_modified?

    @tracker.update_timestamps
    assert_false @tracker.config_modified?
  end


  def test_config_modifications_should_return_true_if_local_config_was_deleted    
    @sandbox.new :file => 'installer_config.rb'
    @tracker.update_timestamps
    @sandbox.remove :file => 'installer_config.rb'
    assert @tracker.config_modified?
  end


  def test_config_modifications_should_return_true_if_central_config_was_deleted
    @sandbox.new :file => 'work/installer_config.rb'
    @tracker.update_timestamps
    @sandbox.remove :file => 'work/installer_config.rb'    
    assert @tracker.config_modified?
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
