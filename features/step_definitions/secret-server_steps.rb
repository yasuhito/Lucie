Given /^secret server holds confidential data "([^\"]*)"$/ do | data |
  @password = "password"
  temp = Tempfile.new( "secret-server" )
  temp.print data
  temp.flush
  encrypted = `openssl enc -pass pass:password -e -aes256 < #{ temp.path }`
  @secret_server = SecretServer.new( encrypted, @password, :verbose => true, :dry_run => true )
  @secret_server.start
end


When /^I connect to secret server$/ do
  @socket = StringIO.new( "" )
  @secret_server.connected( @socket )
end


Then /^I get "([^\"]*)" from secret server$/ do | decrypted |
  @socket.string.chomp.should == decrypted
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
