steps_for( :node_install_help ) do
  When( "I run $command" ) do | command |
    @hoge = command
    # @help_message, @stderr = output_with( command )
  end

  Then( "the help message should look like $message" ) do | message |
    message.should == "hoge\nfuga"
    # @help_message.split.should == message.strip.split( /\s+/ )
  end
end
