Given /^Lucie log file is "([^\"]*)"$/ do | name |
  FileUtils.rm_f name
  Lucie::Log.path = name
end


Then /^nothing logged$/ do
  IO.read( Lucie::Log.path ).split( "\n" ).size.should == 1
end


Then /^"([^\"]*)" logged$/ do | message |
  log = IO.read( Lucie::Log.path ).split( "\n" )
  log.inject( false ) do | result, each |
    result ||= Regexp.new( Regexp.escape( message ) )=~ each
  end.should be_true
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
