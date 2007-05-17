#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'


require "#{RAILS_ROOT}/vendor/file_sandbox/lib/file_sandbox"


class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  def assert_false expression
    assert_equal false, expression
  end


  def assert_raises(arg1 = nil, arg2 = nil)
    expected_error = arg1.is_a?(Exception) ? arg1 : nil
    expected_class = arg1.is_a?(Class) ? arg1 : nil
    expected_message = arg1.is_a?(String) ? arg1 : arg2
    begin 
      yield
      fail "expected error was not raised"
    rescue Test::Unit::AssertionFailedError
      raise
    rescue => e
      raise if e.message == "expected error was not raised"
      assert_equal(expected_error, e) if expected_error
      assert_equal(expected_class, e.class, "Unexpected error type raised") if expected_class
      assert_equal(expected_message, e.message, "Unexpected error message") if expected_message.is_a? String
      assert_matched(expected_message, e.message, "Unexpected error message") if expected_message.is_a? Regexp
    end
  end


  def in_total_sandbox &block
    in_sandbox do | sandbox |
      @dir = File.expand_path( sandbox.root )
      @stdout = "#{ @dir }/stdout"
      @stderr = "#{ @dir }/stderr"
      @prompt = "#{ @dir } #{ Platform.user }$"
      yield sandbox
    end
  end


  def with_sandbox_installer &block
    in_total_sandbox do |sandbox|
      FileUtils.mkdir_p( "#{ sandbox.root }/work" )
      
      installer = Installer.new( 'my_installer' )
      installer.path = sandbox.root
      
      yield sandbox, installer
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
