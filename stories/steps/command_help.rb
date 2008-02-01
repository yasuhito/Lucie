steps_for( :command_help ) do
  When( 'I run $command' ) do | command |
    @help_message = output_with( command )
  end


  Then( 'the first line of the help message should be a usage example' ) do
    @help_message.split( "\n" ).first.should match( /^usage:/ )
  end


  Then( 'the help message should include a description of $short_option and $long_option option' ) do | sopt, lopt |
    extract_options( @help_message ).include?( [ sopt, lopt ] ).should be_true
  end
end