require File.dirname( __FILE__ ) + '/../test_helper'


class NodesTest < Test::Unit::TestCase
  include FileSandbox


  def test_summary_gives_no_nodes_available
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      assert_equal 'No nodes available', Nodes.summary( 'INSTALLER_NAME' )
    end
  end


  def test_summary_all_node_is___UP___
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      sandbox.new :file => 'NODE-1/INSTALLER_NAME'
      sandbox.new :file => 'NODE-1/00:00:00:00:00:01'
      sandbox.new :file => 'NODE-1/install-10/install_status.success'

      sandbox.new :file => 'NODE-2/INSTALLER_NAME'
      sandbox.new :file => 'NODE-2/00:00:00:00:00:02'
      sandbox.new :file => 'NODE-2/install-20/install_status.success'

      assert_equal '2 nodes UP, 0 nodes DOWN', Nodes.summary( 'INSTALLER_NAME' )
    end
  end


  def test_summary_all_node_is___DOWN___
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      sandbox.new :file => 'NODE-1/INSTALLER_NAME'
      sandbox.new :file => 'NODE-1/00:00:00:00:00:01'
      sandbox.new :file => 'NODE-1/install-10/install_status.failure'

      sandbox.new :file => 'NODE-2/INSTALLER_NAME'
      sandbox.new :file => 'NODE-2/00:00:00:00:00:02'
      sandbox.new :file => 'NODE-2/install-20/install_status.incomplete'

      assert_equal '0 nodes UP, 2 nodes DOWN', Nodes.summary( 'INSTALLER_NAME' )
    end
  end


  def test_summary
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      sandbox.new :file => 'NODE-1/INSTALLER_NAME'
      sandbox.new :file => 'NODE-1/00:00:00:00:00:01'
      sandbox.new :file => 'NODE-1/install-10/install_status.success'

      sandbox.new :file => 'NODE-2/INSTALLER_NAME'
      sandbox.new :file => 'NODE-2/00:00:00:00:00:02'
      sandbox.new :file => 'NODE-2/install-20/install_status.success'

      sandbox.new :file => 'NODE-3/INSTALLER_NAME'
      sandbox.new :file => 'NODE-3/00:00:00:00:00:03'
      sandbox.new :file => 'NODE-3/install-30/install_status.failure'

      sandbox.new :file => 'NODE-4/INSTALLER_NAME'
      sandbox.new :file => 'NODE-4/00:00:00:00:00:04'
      sandbox.new :file => 'NODE-4/install-40/install_status.incomplete'

      sandbox.new :file => 'NODE-5/OTHER_INSTALLER_NAME'
      sandbox.new :file => 'NODE-5/00:00:00:00:00:05'
      sandbox.new :file => 'NODE-5/install-50/install_status.incomplete'

      assert_equal '2 nodes UP, 2 nodes DOWN', Nodes.summary( 'INSTALLER_NAME' )
    end
  end
end
