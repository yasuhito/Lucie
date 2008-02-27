ActionController::Routing::Routes.draw do |map|

  map.home '', Configuration.default_page

  map.resources :installers, :nodes, :node

  map.installer_without_builds 'builds/:installer', :controller => 'builds', :action => 'show'
  map.build 'builds/:installer/:build', :controller => 'builds', :action => 'show', :build => /[^\/]+/

  map.build_artifact 'builds/:installer/:build/*path', :controller => 'builds', :action => 'artifact', :build => /[^\/]+/
  map.code 'installers/code/:installer/*path', :controller => 'installers', :action => 'code'

  map.plugin_doc_list 'documentation/plugins', :controller => 'documentation', :action => 'plugins'
  map.plugin_doc 'documentation/plugins/:type/:name', :controller => 'documentation', :action => 'plugins', :name => /[^\/]+/
  map.document 'documentation/*path', :controller => 'documentation', :action => 'get'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

  # Route for CCTray.NET
  map.connect 'XmlStatusReport.aspx', :controller => 'installers', :action => 'index', :format => 'cctray'

end
