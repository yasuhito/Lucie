#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname(__FILE__) + '/../test_helper'


class SubversionTest < Test::Unit::TestCase
  LOG_ENTRY = <<-EOF
<log>
<logentry revision="18">
  <author>alexey</author>
  <date>2006-01-11T13:58:58.000007Z</date>
  <msg>Goofin around with integration test for the builder</msg>
</logentry>
<logentry revision="17">
  <author>alexey</author>
  <date>2006-01-11T12:44:54.000007Z</date>
  <msg>Moved builder from vendor, made bulder's integration tests talk to a subversion repository in the local file system</msg>
</logentry>
<logentry revision="15">
  <author>stellsmi</author>
  <date>2006-01-11T10:37:32.000007Z</date>
  <msg>integration test does a checkout</msg>
</logentry>
</log>
EOF
#'


  def test_latest_revision
    svn = Subversion.new

    svn.expects( :info ).with( dummy_project ).returns( Subversion::Info.new( 10, 10 ) )
    svn.expects( :execute ).with( 'svn --non-interactive log --revision HEAD:10 --verbose --xml', { :stderr => './svn.err' } ).yields( StringIO.new( LOG_ENTRY ) )

    revision = svn.latest_revision( dummy_project )

    assert_equal 18, revision.number
  end


  DummyProject = Struct.new :local_checkout, :path


  def dummy_project
    DummyProject.new '.', '.'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
