Given /^an encrypted file with contents "([^\"]*)" \(password = "([^\"]*)"\)$/ do | data, password |
  @password = password
  @encrypted = Tempfile.new( "secret-server" )
  raw = Tempfile.new( "secret-server" )
  raw.print data
  raw.flush
  system "openssl enc -pass pass:#{ @password } -e -aes256 < #{ raw.path } > #{ @encrypted.path }"
end


Given /^a confidential data server started with the encrypted file$/ do
  @confidential_data_server = ConfidentialDataServer.new( @encrypted.path, @password, { :verbose => true, :dry_run => true } )
  @confidential_data_server.start
end


When /^I try to connect to the server$/ do
  @socket = StringIO.new( "" )
  @confidential_data_server.__send__ :reply_to, @socket
end


Then /^I get a decrypted string "([^\"]*)" from the server$/ do | decrypted |
  @socket.string.chomp.should == decrypted
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
