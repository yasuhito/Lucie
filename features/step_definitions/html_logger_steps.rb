Given /^html logger started$/ do
  @messenger = StringIO.new( "" )
  install_options = { :suite => "lenny", :ldb_repository => "http://ldb.repository.org/", :package_repository => "http://cdn.debian.org/", :http_proxy => "http://proxy.org:3128/" }
  @html_logger = Lucie::Logger::HTML.new( :verbose => true, :dry_run => true, :messenger => @messenger )
  @html_logger.start install_options
end


Then /^html log refreshed automatically$/ do
  refresh_html = %{<meta http-equiv="Refresh" content="#{ Lucie::Logger::HTML::REFRESH_INTERVAL }">}
  history.join( "\n" ).should match( Regexp.new( Regexp.escape( refresh_html ) ) )
end


When /^the node "([^\"]*)" updated its status "([^\"]*)"$/ do | name, status |
  @html_logger.update_status Nodes.find( name ), status
end


When /^html logger updated$/ do
  @html_logger.update_html
end


Then /^status of "([^\"]*)" is "([^\"]*)"$/ do | name, status |
  history.join( "\n" ).should match( Regexp.new( status ) )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

