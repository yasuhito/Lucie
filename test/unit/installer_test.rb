#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class InstallerTest < Test::Unit::TestCase
  def setup
    @installer = Installer.new( 'LEMMINGS' )
  end
  

  def test_default_scheduler
    assert_equal PollingScheduler, @installer.scheduler.class
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
