def utils_opts
  { :verbose => @verbose, :dry_run => @dry_run }
end


Given /^\-\-dry\-run option is on$/ do
  @dry_run = true
end


Given /^a file "([^\"]*)" exists$/ do | name |
  system "touch #{ name }"
end


When /^I execute rm \-f "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  Lucie::Utils.rm_f name, utils_opts, @messenger
end


When /^I write file "([^\"]*)" with "([^\"]*)"$/ do | name, body |
  @messenger = StringIO.new( "" )
  Lucie::Utils.write_file name, body, utils_opts, @messenger
end


When /^I sudo write file "([^\"]*)" with "([^\"]*)"$/ do | name, body |
  @messenger = StringIO.new( "" )
  Lucie::Utils.write_file name, body, utils_opts.merge( :sudo => true ), @messenger
end


When /^I execute touch "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  Lucie::Utils.touch name, utils_opts, @messenger
end


When /^I run "([^\"]*)"$/ do | command |
  @messenger = StringIO.new( "" )
  begin
    Lucie::Utils.run command, utils_opts, @messenger
  rescue => e
    @last_error = e
  end
end


When /^I execute mkdir "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  Lucie::Utils.mkdir_p name, utils_opts, @messenger
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
