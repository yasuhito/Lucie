steps_for :node do
  Given '$node_name is already added and is enabled with $installer installer' do | node, installer |
    add_fresh_node node, :installer => installer
  end


  Given '$node_name is already added and is disabled' do | node |
    add_fresh_node node
  end


  Given 'no node is added yet' do
    FileUtils.rm_r Dir.glob( File.join( Configuration.nodes_directory, '*' ) )
  end


  When 'I run $command' do | command |
    @output = output_with( command )
  end


  Then "the output should look like '$message'" do | message |
    @output.split( "\n" ).collect do | each |
      each.strip
    end.include?( message ).should be_true
  end
end

