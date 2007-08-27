require File.dirname( __FILE__ ) + '/../test_helper'


class InstallersTest < Test::Unit::TestCase
  include FileSandbox


  def test_self_load_all_returns_empty_array
    in_sandbox do | sandbox |
      Configuration.expects( :installers_directory ).at_least_once.returns( sandbox.root )

      assert_equal [], Installers.load_all.list
    end
  end


  def test_load_all_returns_empty_array
    in_sandbox do | sandbox |
      assert_equal [], Installers.new( sandbox.root ).load_all.list
    end
  end


  def test_self_load_all_returns_array_of_installer
    in_sandbox do | sandbox |
      sandbox.new_empty_file 'INSTALLER_1/installer.rb'
      sandbox.new_empty_file 'INSTALLER_2/installer.rb'
      sandbox.new_empty_file 'INSTALLER_3/installer.rb'
      Configuration.expects( :installers_directory ).at_least_once.returns( sandbox.root )

      installers = Installers.load_all

      assert_equal 3, installers.size
      assert_equal 'INSTALLER_1', installers.sort_by_name[ 0 ].name
      assert_equal 'INSTALLER_2', installers.sort_by_name[ 1 ].name
      assert_equal 'INSTALLER_3', installers.sort_by_name[ 2 ].name
    end
  end


  def test_load_all_returns_array_of_installer
    in_sandbox do | sandbox |
      sandbox.new_empty_file 'INSTALLER_1/installer.rb'
      sandbox.new_empty_file 'INSTALLER_2/installer.rb'
      sandbox.new_empty_file 'INSTALLER_3/installer.rb'

      installers = Installers.new( sandbox.root ).load_all

      assert_equal 3, installers.size
      assert_equal 'INSTALLER_1', installers.sort_by_name[ 0 ].name
      assert_equal 'INSTALLER_2', installers.sort_by_name[ 1 ].name
      assert_equal 'INSTALLER_3', installers.sort_by_name[ 2 ].name
    end
  end


  def test_find___fail___
    in_sandbox do | sandbox |
      Configuration.expects( :installers_directory ).at_least_once.returns( sandbox.root )

      assert_nil Installers.find( 'DUMMY_INSTALLER' )
    end
  end


  def test_find___success___
    in_sandbox do | sandbox |
      sandbox.new_empty_file 'DUMMY_INSTALLER/installer.rb'
      Configuration.expects( :installers_directory ).at_least_once.returns( sandbox.root )

      assert_kind_of Installer, Installers.find( 'DUMMY_INSTALLER' )
    end
  end


  def test_append___success___
    in_sandbox do | sandbox |
      installer_mock = mock( 'INSTALLER' )
      source_control_mock = mock( 'SOURCE_CONTROL' )

      installer_mock.expects( :name ).at_least_once.returns( 'DUMMY_INSTALLER' )
      installer_mock.expects( :path= ).times( 1 )
      installer_mock.expects( :path ).at_least_once.returns( File.join( sandbox.root, 'DUMMY_INSTALLER' ) )
      installer_mock.expects( :source_control ).returns( source_control_mock ).times( 1 )
      source_control_mock.expects( :checkout ).times( 1 )

      installers = Installers.new( sandbox.root )

      assert_nothing_raised do
        installers << installer_mock
      end
      # assert installer direcotry created
      assert File.directory?( File.join( sandbox.root, 'DUMMY_INSTALLER' ) )
      # assert work directory (checkout directory) created
      assert File.directory?( File.join( sandbox.root, 'DUMMY_INSTALLER', 'work' ) )
      # assert lucie config generated.
      assert File.exists?( File.join( sandbox.root, 'DUMMY_INSTALLER', 'lucie_config.rb' ) )
    end
  end


  def test_append_uses_config_in_subversion_and___success___
    in_sandbox do | sandbox |
      sandbox.new_empty_file 'DUMMY_INSTALLER/work/lucie_config.rb'

      installer_mock = mock( 'INSTALLER' )
      source_control_mock = mock( 'SOURCE_CONTROL' )

      installer_mock.expects( :name ).at_least_once.returns( 'DUMMY_INSTALLER' )
      installer_mock.expects( :path= ).times( 1 )
      installer_mock.expects( :path ).at_least_once.returns( File.join( sandbox.root, 'DUMMY_INSTALLER' ) )
      installer_mock.expects( :source_control ).returns( source_control_mock ).times( 1 )
      source_control_mock.expects( :checkout ).times( 1 )

      installers = Installers.new( sandbox.root )

      assert_nothing_raised do
        installers << installer_mock
      end
      # assert installer direcotry created
      assert File.directory?( File.join( sandbox.root, 'DUMMY_INSTALLER' ) )
      # assert work directory (checkout directory) created
      assert File.directory?( File.join( sandbox.root, 'DUMMY_INSTALLER', 'work' ) )
      # assert lucie config NOT generated.
      assert !File.exists?( File.join( sandbox.root, 'DUMMY_INSTALLER', 'lucie_config.rb' ) )
    end
  end


  def test_append_invalid_installer___fail___
    in_sandbox do | sandbox |
      installers = Installers.new( sandbox.root )
      assert_raises( NoMethodError ) do
        installers << 'INSTALLER'
      end
    end
  end


  def test_append_existing_installer___fail___
    installer_mock = mock( 'INSTALLER' )
    installer_mock.expects( :name ).times( 1 ).returns( 'DUMMY_INSTALLER' )

    installers = Installers.new
    installers.list << installer_mock

    assert_raises( RuntimeError ) do
      installers << installer_mock
    end
  end
end
