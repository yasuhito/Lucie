#!/usr/bin/env ruby
#
# $Id: tc_progress.rb 2 2007-04-24 02:06:39Z yasuhito $
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 2 $
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class InstallersTest < Test::Unit::TestCase
  include FileSandbox


  def test_load_all
    in_sandbox do | sandbox |
      sandbox.new :file => 'one/installer.rb', :with_content => ''
      sandbox.new :file => 'two/installer.rb', :with_content => ''

      installers = Installers.new( sandbox.root )
      installers.load_all

      assert_equal 'one', installers[ 0 ].name
      assert_equal 'two', installers[ 1 ].name
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
