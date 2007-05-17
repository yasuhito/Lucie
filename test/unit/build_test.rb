#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname(__FILE__) + '/../test_helper'


class BuildTest < Test::Unit::TestCase
  include FileSandbox


  def test_initialize_should_load_status_file_and_build_log
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-2/build_status.success.in9.235s'
      sandbox.new :file => 'build-2/build.log', :with_content => 'some content'
      build = Build.new( installer, 2 )
  
      assert_equal 2, build.label
      assert_equal true, build.successful?
      assert_equal 'some content', build.output
    end
  end


  def test_initialize_should_load_failed_status_file
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-2/build_status.failed.in2s'
      build = Build.new( installer, 2 )
  
      assert_equal 2, build.label
      assert_equal true, build.failed?
    end
  end


  def test_output_grabs_log_file_when_file_exists
    with_sandbox_installer do | sandbox, installer |
      File.expects( :read ).with( "#{ installer.path }/build-1/build.log" ).returns( [ 'line 1', 'line 2' ] )
      assert_equal [ 'line 1', 'line 2' ], Build.new( installer, 1 ).output
    end
  end


  def test_output_gives_empty_string_when_file_does_not_exist
    with_sandbox_installer do | sandbox, installer |
      File.expects( :read ).with( "#{ installer.path }/build-1/build.log" ).raises( StandardError )
      assert_equal '', Build.new( installer, 1 ).output
    end
  end


  def test_successful?
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.Success'
      sandbox.new :file => 'build-3/build_status.failure'
      sandbox.new :file => 'build-4/build_status.crap'
      sandbox.new :file => 'build-5/foo'
  
      assert Build.new( installer, 1 ).successful?
      assert Build.new( installer, 2 ).successful?
      assert !Build.new( installer, 3 ).successful?
      assert !Build.new( installer, 4 ).successful?
      assert !Build.new( installer, 5 ).successful?
    end
  end


  def test_incomplete?
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.incomplete'
      sandbox.new :file => 'build-2/build_status.something_else'
  
      assert Build.new( installer, 1 ).incomplete?
      assert !Build.new( installer, 2 ).incomplete?
    end
  end


  def test_run_successful_build
    with_sandbox_installer do | sandbox, installer |
      expected_build_directory = File.join( sandbox.root, 'build-123' )
  
      build = Build.new( installer, 123 )
  
      expected_command = build.rake
      expected_build_log = File.join( expected_build_directory, 'build.log' )
      expected_redirect_options = {
        :stdout => expected_build_log,
        :stderr => expected_build_log,
        :escape_quotes => false
      }
      Time.expects( :now ).at_least( 2 ).returns( Time.at( 0 ), Time.at( 3.2 ) )
      build.expects( :execute ).with( build.rake, expected_redirect_options ).returns( 'hi, mom!' )

      BuildStatus.any_instance.expects( :start! )
      BuildStatus.any_instance.expects( :succeed! ).with( 4 )
      BuildStatus.any_instance.expects( :fail! ).never

      build.run
    end
  end


  def test_run_stores_settings
    with_sandbox_installer do |sandbox, installer|
      expected_build_directory = File.join(sandbox.root, 'build-123')
      installer.stubs(:config_file_content).returns("cool installer settings")
  
      build = Build.new(installer, 123)
      build.stubs(:execute)

      build.run

      assert_equal 'cool installer settings', file('build-123/installer_config.rb').contents
      assert_equal 'cool installer settings', Build.new(installer, 123).installer_settings
    end
  end


  def test_run_unsuccessful_build
    with_sandbox_installer do |sandbox, installer|
      expected_build_directory = File.join(sandbox.root, 'build-123')
  
      build = Build.new(installer, 123)
  
      expected_build_log = File.join(expected_build_directory, 'build.log')
      expected_redirect_options = {
        :stdout => expected_build_log,
        :stderr => expected_build_log,
        :escape_quotes => false
      }
  
      build.expects(:execute).with(build.rake, expected_redirect_options).raises(CommandLine::ExecutionError)
      Time.stubs(:now).returns(Time.at(1))
      BuildStatus.any_instance.expects(:'start!')
      BuildStatus.any_instance.expects(:'fail!').with(0)  
      build.run
    end
  end


  def test_warn_on_mistake_check_out_if_trunk_dir_exists
    with_sandbox_installer do |sandbox, installer|
      sandbox.new :file => "work/trunk/rakefile"
    
      expected_build_directory = File.join(sandbox.root, 'build-123')
  
      build = Build.new(installer, 123)
  
      expected_build_log = File.join(expected_build_directory, 'build.log')
      expected_redirect_options = {
        :stdout => expected_build_log,
        :stderr => expected_build_log,
        :escape_quotes => false
      }
  
      build.expects(:execute).with(build.rake, expected_redirect_options).raises(CommandLine::ExecutionError)
      build.run
      
      log = File.open(expected_build_log){|f| f.read }
      assert_match /trunk exists/, log
    end
  end


  def test_status
    with_sandbox_installer do |sandbox, installer|
      BuildStatus.any_instance.expects(:to_s)
      Build.new(installer, 123).status
    end
  end


  def test_build_command_customization
    with_sandbox_installer do |sandbox, installer|
      build_with_defaults = Build.new(installer, '1')
      assert_match(/cc_build.rake'; ARGV << '--nosearch' << 'cc:build'/, build_with_defaults.command)
      assert_nil build_with_defaults.rake_task
  
      installer.rake_task = 'my_build_task'
      build_with_custom_rake_task = Build.new(installer, '2')
      assert_match(/cc_build.rake'; ARGV << '--nosearch' << 'cc:build'/, build_with_custom_rake_task.command)
      assert_equal 'my_build_task', build_with_custom_rake_task.rake_task
  
      installer.rake_task = nil
      installer.build_command = 'my_build_script.sh'
      build_with_custom_script = Build.new(installer, '3')
      assert_equal 'my_build_script.sh', build_with_custom_script.command
      assert_nil build_with_custom_script.rake_task
    end
  end


  def test_build_should_know_about_additional_artifacts
    with_sandbox_installer do |sandbox, installer|
      sandbox.new :file => "build-1/coverage/index.html"
      sandbox.new :file => "build-1/coverage/units/index.html"
      sandbox.new :file => "build-1/coverage/functionals/index.html"
      sandbox.new :file => "build-1/foo"
      sandbox.new :file => "build-1/foo.txt"
      sandbox.new :file => "build-1/installer_config.rb"
      sandbox.new :file => "build-1/plugin_errors.log"
      sandbox.new :file => "build.log"
      sandbox.new :file => "build_status.failure"
      sandbox.new :file => "changeset.log"

      
      build = Build.new(installer, 1)
      assert_equal(%w(coverage foo foo.txt), build.additional_artifacts.sort)
    end
  end


  def test_build_should_fail_if_installer_config_is_invalid
    with_sandbox_installer do |sandbox, installer|
      expected_build_directory = File.join(sandbox.root, 'build-123')
      installer.stubs(:config_file_content).returns("cool installer settings")
      installer.stubs(:error_message).returns("some installer config error")
      installer.expects(:config_valid?).returns(false)
      build = Build.new(installer, 123)
      build.run
      assert build.failed?
      log_message = File.open("build-123/build.log"){|f| f.read }
      assert_equal "some installer config error", log_message
    end
  end


  def test_should_pass_error_to_build_status_if_config_file_is_invalid
    with_sandbox_installer do |sandbox, installer|
      sandbox.new :file => "build-1/build.log"
      installer.stubs(:error_message).returns("fail message")
      installer.stubs(:config_valid?).returns(false)
      
      build = Build.new(installer, 1)
      build.run
      assert_equal "fail message", File.open("build-1/build_status.failed.in0s"){|f|f.read}
      assert_equal "config error", build.brief_error
    end   
  end


  def test_should_pass_error_to_build_status_if_plugin_error_happens
    with_sandbox_installer do |sandbox, installer|
      sandbox.new :file => "build-1/build_status.success.in0s"
      build = Build.new(installer, 1)
      build.stubs(:plugin_errors).returns("plugin error")
      assert_equal "plugin error", build.brief_error
    end   
  end    


  def test_should_generate_build_url_with_dashboard_url
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.success.in0s'
      build = Build.new( installer, 1 )

      dashboard_url = 'http://www.my.com'
      Configuration.expects( :dashboard_url ).returns( dashboard_url )
      assert_equal "#{ dashboard_url }/builds/#{ installer.name }/#{ build.to_param }", build.url
      
      Configuration.expects( :dashboard_url ).returns( nil )
      assert_raise( RuntimeError ) do
        build.url
      end
    end   
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
