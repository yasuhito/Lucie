Given /^secret server holds confidential data "([^\"]*)"$/ do | data |
  encrypted = `echo "#{ data }" | openssl enc -pass pass:hoge -e -aes256`
  secret_server = SecretServer.new( encrypted )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
