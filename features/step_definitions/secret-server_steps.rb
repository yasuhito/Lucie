Given /^secret server holds confidential data "([^\"]*)"$/ do | data |
  @password = "password"
  encrypted = Tempfile.new( "secret-server" )
  raw = Tempfile.new( "secret-server" )
  raw.print data
  raw.flush
  system "openssl enc -pass pass:password -e -aes256 < #{ raw.path } > #{ encrypted.path }"
  encrypted.flush
  @secret_server = SecretServer.new( encrypted.path, @password, :verbose => true, :dry_run => true )
  @secret_server.start
end


When /^I connect to secret server$/ do
  @socket = StringIO.new( "" )
  @secret_server.__send__ :connected, @socket
end


Then /^I get "([^\"]*)" from secret server$/ do | decrypted |
  @socket.string.chomp.should == decrypted
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
