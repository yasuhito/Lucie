Story "Remove a node with 'node remove' command", %(
  As a cluster administrator
  I want to remove a node using 'node remove' command
  So that I can remove a node from the system) do

  Scenario 'remove a node' do
    Given 'a node named', 'TEST_NODE' do | node_name |
      add_fresh_node node_name
    end

    When 'I remove the node', 'TEST_NODE' do | node_name |
      system( "./node remove #{ node_name } 2>&1 >/dev/null" )
    end

    Then 'the following directory should be removed:', File.join( './nodes', 'TEST_NODE' ) do | node_directory |
      FileTest.exists?( node_directory ).should_not be_true
    end
  end

  Scenario 'node remove fails' do
    When 'I remove non-existing node named', 'NO_SUCH_NODE' do | node_name |
      Open3.popen3( "./node remove #{ node_name } 2>&1 >/dev/null" ) do | stdin, stdout, stderr |
        @error_message = stdout.read.chomp
      end
    end

    Then 'I get error look like:', "FAILED: Node 'NO_SUCH_NODE' not found." do | message |
      @error_message.should == message
    end
  end
end


Story 'Trace node remove command',
%(As a cluster administrator
  I can trace a failed command
  So that I can report detailed backtrace to Lucie developers) do

  Scenario 'run node remove with --trace option' do
    When 'I run a command that fails with --trace option' do
      @error_message = output_with( './node remove NO_SUCH_NODE --trace' )
    end

    Then 'I get backtrace' do
      @error_message.should match( /\(RuntimeError\)/ )
      @error_message.should match( /^\s+from/ )
    end
  end
end
