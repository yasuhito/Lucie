Given /^new service "([^\"]*)", with prerequisite "([^\"]*)"$/ do | klass, prerequisite |
  eval <<-EOF
  class Service
    class #{ klass } < Service
      prerequisite "#{ prerequisite }"
    end
  end
EOF
end


When /^I try to check prerequisites$/ do
  @messenger = StringIO.new
  Service.check_prerequisites( :dry_run => true, :messenger => @messenger )
end


Then /^"([^\"]*)" checked$/ do | package |
  @messenger.string.should match( /^Checking #{ regexp_from( package ) } \.\.\. (INSTALLED|NOT INSTALLED)$/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
