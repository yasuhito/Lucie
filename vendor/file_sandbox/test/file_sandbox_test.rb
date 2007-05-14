require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../lib/file_sandbox')

class FileSandboxTest < Test::Unit::TestCase
  include FileSandbox

  def test_sandbox_cleans_up_file
    in_sandbox do |sandbox|
      name = sandbox.root + "/a.txt"

      File.open(name, "w") {|f| f << "something"}

      assert File.exist?(name)
    end
    assert !File.exist?(name)
  end

  def test_file_exist
    in_sandbox do |sandbox|
      assert !file('a.txt').exists?
      File.open(sandbox.root + "/a.txt", "w") {|f| f << "something"}
      assert file('a.txt').exist?
    end
  end

  def test_create_file
    in_sandbox do |sandbox|
      assert !file('a.txt').exists?

      sandbox.new :file => 'a.txt'
      assert file('a.txt').exist?
      
      sandbox.new :file => 'b', :with_contents => 'some'
      assert_equal 'some', file('b').contents
      
      sandbox.new :file => 'c', :with_contents => 'thing'
      assert_equal 'thing', file('c').contents
      
      assert_raises("unexpected keys 'contents'") {
        sandbox.new :file => 'd', :contents => 'crap'
      }
    end
  end
  
  def test_remove_file
    in_sandbox do |sandbox|
      sandbox.new :file => 'foo'
      sandbox.remove :file => 'foo'
      
      assert !file('foo').exists?
    end
  end
  
  private
  
  def assert_raises(string)
    begin
      yield
    rescue
      assert_equal string, $!.message, "wrong exception thrown"
      return
    end
    fail "expected exception '#{string}'"
  end
end

