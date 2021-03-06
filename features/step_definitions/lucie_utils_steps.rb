def utils_options
  { :verbose => @verbose,
    :dry_run => @dry_run,
    :messenger => @messenger }
end


Given /^\-\-dry\-run option is on$/ do
  @dry_run = true
end


Given /^a file "([^\"]*)" exists$/ do | name |
  system "touch #{ name }"
end


When /^I execute rm \-f "([^\"]*)"$/ do | name |
  @messenger = StringIO.new
  Lucie::Utils.rm_f name, utils_options
end


When /^I write file "([^\"]*)" with "([^\"]*)"$/ do | name, body |
  @messenger = StringIO.new
  Lucie::Utils.write_file name, body, utils_options
end


When /^I sudo write file "([^\"]*)" with "([^\"]*)"$/ do | name, body |
  @messenger = StringIO.new
  Lucie::Utils.write_file name, body, utils_options.merge( :sudo => true )
end


When /^I execute touch "([^\"]*)"$/ do | name |
  @messenger = StringIO.new
  Lucie::Utils.touch name, utils_options
end


When /^I run "([^\"]*)"$/ do | command |
  @messenger = StringIO.new
  begin
    Lucie::Utils.run command, utils_options
  rescue => e
    @error = e
  end
end


When /^I execute mkdir "([^\"]*)"$/ do | name |
  @messenger = StringIO.new
  Lucie::Utils.mkdir_p name, utils_options
end


Then /^"([^\"]*)" created$/ do | name |
  FileTest.exists?( name ).should == true
end


Then /^"([^\"]*)" not created$/ do | name |
  FileTest.exists?( name ).should == false
end


Then /^contents of "([^\"]*)" is "([^\"]*)"$/ do | name, body |
  IO.read( name ).should == body
end


Then /^"([^\"]*)" removed$/ do | name |
  FileTest.exists?( name ).should == false
end


Then /^"([^\"]*)" not removed$/ do | name |
  FileTest.exists?( name ).should == true
end


Then /^directory "([^\"]*)" created$/ do | name |
  FileTest.directory?( name ).should == true
end


Then /^directory "([^\"]*)" not created$/ do | name |
  FileTest.directory?( name ).should == false
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
