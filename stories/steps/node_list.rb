require 'fileutils'


steps_for :node do
  ##############################################################################
  # GIVEN
  ##############################################################################


  Given "nodes_directory is '$path'" do | path |
    FileUtils.mkdir_p path
    Configuration.nodes_directory = path
  end


  Given 'no node is added yet' do
    FileUtils.rm_r Dir.glob( File.join( Configuration.nodes_directory, '*' ) )
  end


  Given "node '$node_name' is added" do | node |
    add_fresh_node node
  end


  Given "node '$node_name' is enabled with installer '$installer'" do | node, installer |
    enable_node node, installer
  end


  Given "node '$node' is disabled" do | node |
    disable_node node
  end


  Given "node '$node_name' succeeded to install" do | node |
    add_success_log node
    disable_node node
  end


  Given "node '$node_name' failed to install" do | node |
    add_failure_log node
  end


  Given "node '$node_name' is incomplete" do | node |
    add_incomplete_log node
  end


  ##############################################################################
  # WHEN
  ##############################################################################


  When "I run '$command'" do | command |
    @output, @stderr = output_with( command )

    if $DEBUG
      @output and @output.split( "\n" ).each do | each |
        $stderr.puts "stdout: #{ each }"
      end
      @stderr and @stderr.split( "\n" ).each do | each |
        $stderr.puts "stderr: #{ each }"
      end
    end
  end


  ##############################################################################
  # THEN
  ##############################################################################


  Then "the output should include '$message'" do | message |
    @output.split( "\n" ).collect do | each |
      each.strip.gsub /\s+/, ' '
    end.include?( message.strip ).should be_true
  end


  Then 'clean up nodes_directory' do
    FileUtils.rm_r Configuration.nodes_directory
  end


  Then "line $n of the output should include '$message'" do | n, message |
    @output.split( "\n" )[ n.to_i ].strip.gsub( /\s+/, ' ' ).include?( message ).should be_true
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
