steps_for( :command_help ) do
  When "I run '$command'" do | command |
    @help_message, = output_with( command )
  end


  Then 'the first line of help message should be a usage example' do
    @help_message.split( "\n" ).first.should match( /^Usage:/ )
  end


  Then "the help message should include a description of '$short_option' and '$long_option' option" do | sopt, lopt |
    extract_options( @help_message ).include?( [ sopt, lopt ] ).should be_true
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
