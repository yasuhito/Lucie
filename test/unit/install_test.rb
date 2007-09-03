require File.dirname(__FILE__) + '/../test_helper'


class InstallTest < Test::Unit::TestCase
  include FileSandbox


  def test_initialize_should_load_status_file_and_build_log
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-2/install_status.success.in9.235s'
      sandbox.new :file => 'install-2/install.log', :with_content => 'SOME CONTENT'
      install = Install.new( node, 2 )

      assert_equal 2, install.label
      assert_equal true, install.successful?
      assert_equal 'SOME CONTENT', install.output
    end
  end


  def test_initialize_should_load_failed_status_file
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-2/install_status.failed.in2s'
      install = Install.new( node, 2 )

      assert_equal 2, install.label
      assert_equal true, install.failed?
    end
  end


  def test_output_grabs_log_file_when_file_exists
    with_sandbox_node do | sandbox, node |
      File.expects( :read ).with( "#{ node.path }/install-1/install.log" ).returns( [ 'LINE 1', 'LINE 2' ] )
      assert_equal [ 'LINE 1', 'LINE 2' ], Install.new( node, 1 ).output
    end
  end


  def test_output_gives_empty_string_when_file_does_not_exist
    with_sandbox_node do | sandbox, node |
      File.expects( :read ).with( "#{ node.path }/install-1/install.log" ).raises( StandardError )
      assert_equal '', Install.new( node, 1 ).output
    end
  end


  def test_successful?
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.success'
      sandbox.new :file => 'install-2/install_status.Success'
      sandbox.new :file => 'install-3/install_status.failure'
      sandbox.new :file => 'install-4/install_status.crap'
      sandbox.new :file => 'install-5/foo'

      assert Install.new( node, 1 ).successful?
      assert Install.new( node, 2 ).successful?
      assert !Install.new( node, 3 ).successful?
      assert !Install.new( node, 4 ).successful?
      assert !Install.new( node, 5 ).successful?
    end
  end


  def test_incomplete?
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.incomplete'
      sandbox.new :file => 'install-2/install_status.something_else'

      assert Install.new( node, 1 ).incomplete?
      assert !Install.new( node, 2 ).incomplete?
    end
  end


  def test_run_successful_install
    with_sandbox_node do | sandbox, node |
      expected_install_directory = File.join( sandbox.root, 'install-123' )

      install = Install.new( node, 123 )

      expected_install_log = File.join( expected_install_directory, 'install.log' )
      expected_redirect_options = {
        :stdout => expected_install_log,
        :stderr => expected_install_log,
        :escape_quotes => false
      }
      Time.expects( :now ).at_least( 2 ).returns( Time.at( 0 ), Time.at( 3.2 ) )
      install.expects( :execute ).with( install.rake, expected_redirect_options )

      InstallStatus.any_instance.expects( :start! )
      InstallStatus.any_instance.expects( :succeed! ).with( 4 )
      InstallStatus.any_instance.expects( :fail! ).never

      install.run
    end
  end


  def test_run_unsuccessful_install
    with_sandbox_node do | sandbox, node |
      expected_install_directory = File.join( sandbox.root, 'install-123' )

      install = Install.new( node, 123 )

      expected_install_log = File.join( expected_install_directory, 'install.log' )
      expected_redirect_options = {
        :stdout => expected_install_log,
        :stderr => expected_install_log,
        :escape_quotes => false
      }
      Time.stubs( :now ).returns( Time.at( 1 ) )
      install.expects( :execute ).with( install.rake, expected_redirect_options ).raises( CommandLine::ExecutionError )

      InstallStatus.any_instance.expects( :start! )
      InstallStatus.any_instance.expects( :fail! ).with( 0 )

      install.run
    end
  end


  def test_status
    with_sandbox_node do | sandbox, node |
      InstallStatus.any_instance.expects( :to_s )
      Install.new( node, 123 ).status
    end
  end
end
