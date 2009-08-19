Given /^new service "([^\"]*)", with prerequisite "([^\"]*)"$/ do | klass, prerequisite |
  eval <<-CLASS
class Service
  class #{ klass } < Service
    prerequisite "#{ prerequisite }"
  end
end
CLASS
end


When /^I try to check prerequisites$/ do
  @messenger = StringIO.new( "" )
  begin
    Service.check_prerequisites( { :dry_run => true }, @messenger )
  rescue => e
    @error = e
  end
end


Then /^"([^\"]*)" checked$/ do | package |
  @error.should == nil
  history.join( "\n" ).should match( /Checking #{ package }/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
